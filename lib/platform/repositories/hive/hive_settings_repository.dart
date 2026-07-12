import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bbeez_one/platform/security/security_service.dart';
import '../settings_repository.dart';

class HiveSettingsRepository implements SettingsRepository {
  static const String _biometricKey = 'biometric_enabled';
  static const String _lastBackupKey = 'last_backup_date';
  static const String _newRecordsKey = 'new_records_count';
  static const String _sensitiveModifiedKey = 'sensitive_record_modified';

  final StreamController<Map<String, dynamic>> _watchController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<Map<String, dynamic>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final privacyEnabled = await SecurityService.getPrivacyScreenEnabled();

    return {
      _biometricKey: prefs.getBool(_biometricKey) ?? false,
      'privacy_screen_enabled': privacyEnabled,
      _lastBackupKey: prefs.getString(_lastBackupKey),
      _newRecordsKey: prefs.getInt(_newRecordsKey) ?? 0,
      _sensitiveModifiedKey: prefs.getBool(_sensitiveModifiedKey) ?? false,
    };
  }

  @override
  Future<dynamic> getById(String key) async {
    final all = await getAll();
    return all[key];
  }

  @override
  Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
    _watchController.add(await getAll());
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    _watchController.add(await getAll());
  }

  @override
  Stream<Map<String, dynamic>> watchAll() async* {
    yield await getAll();
    yield* _watchController.stream;
  }

  @override
  Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await save(_biometricKey, enabled);
  }

  @override
  Future<bool> getPrivacyScreenEnabled() {
    return SecurityService.getPrivacyScreenEnabled();
  }

  @override
  Future<void> setPrivacyScreenEnabled(bool enabled) async {
    await SecurityService.setPrivacyScreenEnabled(enabled);
    _watchController.add(await getAll());
  }

  @override
  Future<Map<String, dynamic>> getBackupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupStr = prefs.getString(_lastBackupKey);
    final lastBackup =
        lastBackupStr != null ? DateTime.parse(lastBackupStr) : null;

    final newRecordsCount = prefs.getInt(_newRecordsKey) ?? 0;
    final sensitiveModified = prefs.getBool(_sensitiveModifiedKey) ?? false;

    final daysSince =
        lastBackup != null ? DateTime.now().difference(lastBackup).inDays : 999;

    return {
      'lastBackup': lastBackup,
      'daysSince': daysSince,
      'newRecords': newRecordsCount,
      'sensitiveModified': sensitiveModified,
    };
  }

  @override
  Future<void> resetBackupTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
    await prefs.setInt(_newRecordsKey, 0);
    await prefs.setBool(_sensitiveModifiedKey, false);
    _watchController.add(await getAll());
  }

  @override
  Future<void> trackRecordSaved({
    required bool isNew,
    required String domainName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (isNew) {
      final count = prefs.getInt(_newRecordsKey) ?? 0;
      await prefs.setInt(_newRecordsKey, count + 1);
    }

    final upper = domainName.toUpperCase();
    if (upper == 'PERSONAL' || upper == 'FINANCE') {
      await prefs.setBool(_sensitiveModifiedKey, true);
    }

    _watchController.add(await getAll());
  }
}
