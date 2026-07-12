import 'package:flutter/foundation.dart';

import 'security_service_impl.dart';

class SecurityService {
  static SecurityServiceImpl get _impl => SecurityServiceImpl.instance;

  static ValueListenable<bool> get privacyEnabled => _impl.privacyEnabled;

  static Future<void> init() => _impl.initialize();

  static Future<void> setSecure(bool enabled) => _impl.setSecure(enabled);

  static Future<bool> getPrivacyScreenEnabled() =>
      _impl.getPrivacyScreenEnabled();

  static Future<void> setPrivacyScreenEnabled(bool enabled) =>
      _impl.setPrivacyScreenEnabled(enabled);

  static Future<bool> isPasswordSet() => _impl.isMasterPasswordSet();

  static Future<void> setNewPassword(String password) =>
      _impl.saveMasterPassword(password);

  static Future<bool> verifyPassword(String password) =>
      _impl.verifyMasterPassword(password);

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _impl.changeMasterPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  static Future<void> resetPassword() => _impl.resetMasterPassword();

  static Future<void> generateKeyIfNeeded() => _impl.generateKeyIfNeeded();

  static Future<Uint8List> getEncryptionKey() => _impl.getEncryptionKey();

  static String encrypt(String? text) => _impl.encrypt(text);

  static String decrypt(String? text) => _impl.decrypt(text);

  static Future<Uint8List?> encryptBackupBytes(Uint8List plainBytes) =>
      _impl.encryptBackupBytes(plainBytes);

  static Future<Uint8List?> decryptBackupBytes(
    Uint8List encryptedBytes, {
    String? password,
    bool allowLocalCredentials = false,
  }) =>
      _impl.decryptBackupBytes(
        encryptedBytes,
        password: password,
        allowLocalCredentials: allowLocalCredentials,
      );

  static Future<void> resetSecurity() => _impl.resetSecurity();
}
