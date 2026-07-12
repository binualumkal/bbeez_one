import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'database_service.dart';

class SecurityService {
  static const _channel = MethodChannel('com.bbeezdigital.one/security');
  
  static final ValueNotifier<bool> privacyEnabled = ValueNotifier(true);

  static Future<void> init() async {
    final enabled = await DatabaseService.getPrivacyScreenEnabled();
    privacyEnabled.value = enabled;
    await setSecure(enabled);
  }

  static Future<void> setSecure(bool enabled) async {
    privacyEnabled.value = enabled;
    try {
      await _channel.invokeMethod('setSecure', enabled);
    } on PlatformException catch (e) {
      debugPrint("Failed to set secure mode: '${e.message}'.");
    }
  }
}
