import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService with WidgetsBindingObserver {

  static final AppLockService instance =
  AppLockService._();

  AppLockService._();

  Timer? _timer;

  bool isLocked = false;

  VoidCallback? onLock;

  Duration _timeout = const Duration(seconds: 50);
  Duration get timeout => _timeout;

  static const String _lockTimeoutKey = 'app_lock_timeout_seconds';

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    await _loadTimeout();
    // Start idle timer immediately on init
    _startTimer();
  }

  Future<void> _loadTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_lockTimeoutKey) ?? 50;
    _timeout = Duration(seconds: seconds);
  }

  Future<void> updateTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockTimeoutKey, seconds);
    _timeout = Duration(seconds: seconds);
    
    // If not currently locked, restart timer with new duration
    if (!isLocked) {
      _startTimer();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  /// Call this when user interacts with the app (taps, scrolls, etc.)
  void resetTimer() {
    if (!isLocked) {
      _startTimer();
    }
  }

  final List<Future<void> Function()> _lockListeners = [];

  void addLockListener(Future<void> Function() listener) {
    _lockListeners.add(listener);
  }

  void removeLockListener(Future<void> Function() listener) {
    _lockListeners.remove(listener);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Trigger any pre-lock saves when app goes to background
      for (var listener in _lockListeners) {
        listener();
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (isLocked) {
        onLock?.call();
      } else {
        // Reset timer when coming back from short background stay
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer(timeout, () async {
      // Trigger pre-lock saves and wait for them
      await Future.wait(_lockListeners.map((l) => l()));

      isLocked = true;
      
      // If we are currently in foreground, trigger lock immediately
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        onLock?.call();
      }
    });
  }

  void unlock() {
    isLocked = false;
    _startTimer(); // Restart tracking after unlock
  }
}
