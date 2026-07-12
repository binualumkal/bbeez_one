import 'package:flutter/foundation.dart';

abstract class SecurityContract {
  ValueListenable<bool> get privacyEnabled;

  Future<void> initialize();

  Future<void> setSecure(bool enabled);

  Future<bool> getPrivacyScreenEnabled();

  Future<void> setPrivacyScreenEnabled(bool enabled);

  Future<bool> isMasterPasswordSet();

  Future<void> saveMasterPassword(String password);

  Future<bool> verifyMasterPassword(String password);

  Future<bool> changeMasterPassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> resetMasterPassword();

  Future<void> generateKeyIfNeeded();

  Future<Uint8List> getEncryptionKey();

  String encrypt(String? text);

  String decrypt(String? text);

  Future<Uint8List?> encryptBackupBytes(Uint8List plainBytes);

  Future<Uint8List?> decryptBackupBytes(
    Uint8List encryptedBytes, {
    String? password,
    bool allowLocalCredentials = false,
  });

  Future<void> resetSecurity();
}
