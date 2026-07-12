import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {

  static final _key =
  Key.fromUtf8(
    '12345678901234567890123456789012',
  );

  static final _iv =
  IV.fromUtf8('1234567890123456'); // Fixed IV for consistency across restarts

  static final _aes =
  Encrypter(
    AES(_key),
  );

  static String encrypt(
      String? text,
      ) {
    if (text == null || text.trim().isEmpty) return "";

    return _aes
        .encrypt(
      text,
      iv: _iv,
    )
        .base64;
  }

  static String decrypt(
      String? text,
      ) {
    if (text == null || text.isEmpty) return "";

    try {
      return _aes.decrypt64(
        text,
        iv: _iv,
      );
    } catch (e) {
      // If decryption fails, return original text
      return text;
    }
  }

  // Password-based encryption for Backups
  static Uint8List encryptBytes(Uint8List bytes, String password) {
    final key = Key(Uint8List.fromList(sha256.convert(utf8.encode(password)).bytes));
    final iv = IV.fromLength(16); // Random IV for backup
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encryptBytes(bytes, iv: iv);

    // Prepend IV to the encrypted data so it can be used for decryption
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    result.setAll(0, iv.bytes);
    result.setAll(iv.bytes.length, encrypted.bytes);
    return result;
  }

  static Uint8List? decryptBytes(Uint8List encryptedData, String password) {
    try {
      final key = Key(Uint8List.fromList(sha256.convert(utf8.encode(password)).bytes));

      // Extract IV from the beginning
      final iv = IV(encryptedData.sublist(0, 16));
      final ciphertext = encryptedData.sublist(16);

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decryptBytes(Encrypted(ciphertext), iv: iv);

      return Uint8List.fromList(decrypted);
    } catch (e) {
      return null; // Decryption failed (probably wrong password)
    }
  }
}