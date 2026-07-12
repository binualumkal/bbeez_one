import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart'
    show ValueListenable, ValueNotifier, debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bbeez_one/platform/security/security_contract.dart';

class SecurityServiceImpl implements SecurityContract {
  SecurityServiceImpl._();

  static final SecurityServiceImpl instance = SecurityServiceImpl._();

  static const _channel = MethodChannel('com.bbeezdigital.one/security');

  static const _passwordHashKey = 'master_password_hash';
  static const _passwordSaltKey = 'master_password_salt';
  static const _encryptionKeyKey = 'vault_encryption_key_v2';
  static const _legacyPasswordPrefsKey = 'master_password';
  static const _privacyScreenKey = 'privacy_screen_enabled';

  static const _dataPrefixV2 = 'v2:';
  static const _backupHeaderV2 = 'BBZ2';

  static const _pbkdf2Iterations = 120000;
  static const _pbkdf2Bits = 256;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final _privacyEnabled = ValueNotifier<bool>(true);
  static final _random = Random.secure();
  static final _pbkdf2 = cryptography.Pbkdf2(
    macAlgorithm: cryptography.Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _pbkdf2Bits,
  );
  Uint8List? _cachedEncryptionKey;

  @override
  ValueListenable<bool> get privacyEnabled => _privacyEnabled;

  @override
  Future<void> initialize() async {
    await _migrateLegacyPasswordIfNeeded();
    final enabled = await getPrivacyScreenEnabled();
    _privacyEnabled.value = enabled;
    await setSecure(enabled);
    await generateKeyIfNeeded();
  }

  @override
  Future<void> setSecure(bool enabled) async {
    _privacyEnabled.value = enabled;
    try {
      await _channel.invokeMethod('setSecure', enabled);
    } on PlatformException catch (e) {
      debugPrint("Failed to set secure mode: '${e.message}'.");
    }
  }

  @override
  Future<bool> getPrivacyScreenEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyScreenKey) ?? true;
  }

  @override
  Future<void> setPrivacyScreenEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyScreenKey, enabled);
    await setSecure(enabled);
  }

  @override
  Future<bool> isMasterPasswordSet() async {
    final hash = await _storage.read(key: _passwordHashKey);
    final salt = await _storage.read(key: _passwordSaltKey);
    return (hash?.isNotEmpty ?? false) && (salt?.isNotEmpty ?? false);
  }

  @override
  Future<void> saveMasterPassword(String password) async {
    final existingSalt = await _storage.read(key: _passwordSaltKey);
    final saltBytes = existingSalt != null && existingSalt.isNotEmpty
        ? base64Decode(existingSalt)
        : _randomBytes(32);

    final hashBytes = await _derivePbkdf2(
      secret: Uint8List.fromList(utf8.encode(password)),
      salt: saltBytes,
    );

    await _storage.write(key: _passwordSaltKey, value: base64Encode(saltBytes));
    await _storage.write(key: _passwordHashKey, value: base64Encode(hashBytes));

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_legacyPasswordPrefsKey)) {
      await prefs.remove(_legacyPasswordPrefsKey);
    }
  }

  @override
  Future<bool> verifyMasterPassword(String password) async {
    final hash = await _storage.read(key: _passwordHashKey);
    final salt = await _storage.read(key: _passwordSaltKey);
    if (hash == null || salt == null) return false;

    final expected = base64Decode(hash);
    final saltBytes = base64Decode(salt);
    final actual = await _derivePbkdf2(
      secret: Uint8List.fromList(utf8.encode(password)),
      salt: saltBytes,
    );
    return _constantTimeEquals(actual, expected);
  }

  @override
  Future<bool> changeMasterPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final ok = await verifyMasterPassword(currentPassword);
    if (!ok) return false;
    await saveMasterPassword(newPassword);
    return true;
  }

  @override
  Future<void> resetMasterPassword() async {
    await _storage.delete(key: _passwordHashKey);
    await _storage.delete(key: _passwordSaltKey);
  }

  @override
  Future<void> generateKeyIfNeeded() async {
    final existing = await _storage.read(key: _encryptionKeyKey);
    if (existing != null && existing.isNotEmpty) {
      _cachedEncryptionKey = Uint8List.fromList(base64Decode(existing));
      return;
    }
    await _storage.write(
      key: _encryptionKeyKey,
      value: base64Encode(_randomBytes(32)),
    );
    final saved = await _storage.read(key: _encryptionKeyKey);
    if (saved != null && saved.isNotEmpty) {
      _cachedEncryptionKey = Uint8List.fromList(base64Decode(saved));
    }
  }

  @override
  Future<Uint8List> getEncryptionKey() async {
    await generateKeyIfNeeded();
    final key = await _storage.read(key: _encryptionKeyKey);
    if (key == null || key.isEmpty) {
      throw StateError('Encryption key unavailable');
    }
    _cachedEncryptionKey = Uint8List.fromList(base64Decode(key));
    return _cachedEncryptionKey!;
  }

  @override
  String encrypt(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    if (_cachedEncryptionKey == null) return text;

    final key = enc.Key(_cachedEncryptionKey!);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(text, iv: iv);
    final payload = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return '$_dataPrefixV2${base64Encode(payload)}';
  }

  @override
  String decrypt(String? text) {
    if (text == null || text.isEmpty) return '';
    if (_cachedEncryptionKey == null) return text;

    if (!text.startsWith(_dataPrefixV2)) {
      return text;
    }

    try {
      final raw = base64Decode(text.substring(_dataPrefixV2.length));
      if (raw.length <= 16) return text;

      final iv = enc.IV(raw.sublist(0, 16));
      final cipherBytes = raw.sublist(16);
      final key = enc.Key(_cachedEncryptionKey!);
      final encrypter =
          enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
      final plain = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
      return utf8.decode(plain);
    } catch (_) {
      return text;
    }
  }

  @override
  Future<Uint8List?> encryptBackupBytes(Uint8List plainBytes) async {
    final masterHash = await _storage.read(key: _passwordHashKey);
    final masterSalt = await _storage.read(key: _passwordSaltKey);
    if (masterHash == null || masterSalt == null) return null;

    try {
      final masterHashBytes = Uint8List.fromList(base64Decode(masterHash));
      final masterSaltBytes = Uint8List.fromList(base64Decode(masterSalt));
      final backupSalt = _randomBytes(32);
      final iv = enc.IV.fromSecureRandom(16);
      final backupKey =
          await _derivePbkdf2(secret: masterHashBytes, salt: backupSalt);

      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(backupKey), mode: enc.AESMode.cbc, padding: 'PKCS7'),
      );
      final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

      final header = Uint8List.fromList(utf8.encode(_backupHeaderV2));
      return Uint8List.fromList([
        ...header,
        ...backupSalt,
        ...masterSaltBytes,
        ...iv.bytes,
        ...encrypted.bytes,
      ]);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Uint8List?> decryptBackupBytes(
    Uint8List encryptedBytes, {
    String? password,
    bool allowLocalCredentials = false,
  }) async {
    if (encryptedBytes.length > 84 &&
        utf8.decode(encryptedBytes.sublist(0, 4), allowMalformed: true) ==
            _backupHeaderV2) {
      return _decryptBackupV2(
        encryptedBytes,
        password: password,
        allowLocalCredentials: allowLocalCredentials,
      );
    }
    return _decryptBackupLegacy(encryptedBytes, password ?? '');
  }

  @override
  Future<void> resetSecurity() async {
    await _storage.delete(key: _passwordHashKey);
    await _storage.delete(key: _passwordSaltKey);
    await _storage.delete(key: _encryptionKeyKey);
  }

  Future<void> _migrateLegacyPasswordIfNeeded() async {
    if (await isMasterPasswordSet()) return;

    final prefs = await SharedPreferences.getInstance();
    final legacyPassword = prefs.getString(_legacyPasswordPrefsKey);
    if (legacyPassword == null || legacyPassword.isEmpty) return;

    await saveMasterPassword(legacyPassword);
    await prefs.remove(_legacyPasswordPrefsKey);
  }

  Future<Uint8List?> _decryptBackupV2(
    Uint8List bytes, {
    String? password,
    required bool allowLocalCredentials,
  }) async {
    try {
      final backupSalt = bytes.sublist(4, 36);
      final masterSalt = bytes.sublist(36, 68);
      final iv = enc.IV(bytes.sublist(68, 84));
      final cipherBytes = bytes.sublist(84);

      Uint8List? masterHashBytes;
      if (password != null && password.isNotEmpty) {
        masterHashBytes = await _derivePbkdf2(
          secret: Uint8List.fromList(utf8.encode(password)),
          salt: masterSalt,
        );
      } else if (allowLocalCredentials) {
        final storedHash = await _storage.read(key: _passwordHashKey);
        if (storedHash != null && storedHash.isNotEmpty) {
          masterHashBytes = Uint8List.fromList(base64Decode(storedHash));
        }
      }

      if (masterHashBytes == null) return null;

      final keyBytes = await _derivePbkdf2(
        secret: masterHashBytes,
        salt: backupSalt,
      );

      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(keyBytes), mode: enc.AESMode.cbc, padding: 'PKCS7'),
      );
      final decrypted =
          encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (_) {
      return null;
    }
  }

  Uint8List? _decryptBackupLegacy(Uint8List encryptedData, String password) {
    if (password.isEmpty || encryptedData.length <= 16) return null;

    try {
      final passwordKey = Uint8List.fromList(
        crypto.sha256.convert(utf8.encode(password)).bytes,
      );
      final iv = enc.IV(encryptedData.sublist(0, 16));
      final cipherBytes = encryptedData.sublist(16);

      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(passwordKey), mode: enc.AESMode.cbc, padding: 'PKCS7'),
      );
      final decrypted =
          encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _derivePbkdf2({
    required Uint8List secret,
    required Uint8List salt,
  }) async {
    final derived = await _pbkdf2.deriveKey(
      secretKey: cryptography.SecretKey(secret),
      nonce: salt,
    );
    return Uint8List.fromList(await derived.extractBytes());
  }

  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}
