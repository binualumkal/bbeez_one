import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/biometric_service.dart';
import '../services/notification_service.dart';
import '../services/app_lock_service.dart';
import '../services/security_service.dart';
import '../theme/app_theme.dart';

import 'login_screen.dart';
import 'main_screen.dart';
import 'setup_password_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      await Future.wait([
        DatabaseService.init(),
        NotificationService.init(),
      ]);

      await Future.wait([
        AppLockService.instance.initialize(),
        SecurityService.init(),
      ]);

      final passwordSet = await DatabaseService.isPasswordSet();

      if (!passwordSet) {
        AppLockService.instance.unlock();
        await _ensureMinDuration(startTime);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SetupPasswordScreen()),
        );
        return;
      }

      final biometricEnabled = await DatabaseService.getBiometricEnabled();
      bool biometricAuthenticated = false;

      if (biometricEnabled) {
        final available = await BiometricService.isBiometricAvailable();
        if (available) {
          biometricAuthenticated = await BiometricService.authenticate();
        }
      }

      await _ensureMinDuration(startTime);
      if (!mounted) return;

      if (biometricAuthenticated) {
        AppLockService.instance.unlock();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('Startup error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _ensureMinDuration(DateTime startTime) async {
    final elapsedTime = DateTime.now().difference(startTime);
    const minDuration = Duration(milliseconds: 2000);
    if (elapsedTime < minDuration) {
      await Future.delayed(minDuration - elapsedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.pageBackground,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/bbeez_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'BBeez One',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Secure Data Management',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      AppTheme.primaryAccent.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'PRIVACY • SECURITY • OFFLINE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
