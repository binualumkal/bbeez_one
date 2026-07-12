abstract class SettingsRepository {
  Future<Map<String, dynamic>> getAll();
  Future<dynamic> getById(String key);
  Future<void> save(String key, dynamic value);
  Future<void> delete(String key);
  Stream<Map<String, dynamic>> watchAll();

  Future<bool> getBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> getPrivacyScreenEnabled();
  Future<void> setPrivacyScreenEnabled(bool enabled);

  Future<Map<String, dynamic>> getBackupStatus();
  Future<void> resetBackupTracking();
  Future<void> trackRecordSaved({
    required bool isNew,
    required String domainName,
  });
}
