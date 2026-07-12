import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/domain_model.dart';
import '../models/institution_model.dart';
import '../models/record_model.dart';
import '../models/record_type_model.dart';
import '../models/secret_field_model.dart';
import 'notification_service.dart';

class DatabaseService {

  static late Box<DomainModel> domainBox;
  static late Box<InstitutionModel> institutionBox;
  static late Box<RecordTypeModel> recordTypeBox;
  static late Box<RecordModel> recordBox;

  // =========================
  // INIT DATABASE
  // =========================

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DomainModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(InstitutionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecordTypeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SecretFieldAdapter());
    }

    // Open boxes
    domainBox = await Hive.openBox<DomainModel>('domains', path: dir.path);
    institutionBox = await Hive.openBox<InstitutionModel>('institutions', path: dir.path);
    recordTypeBox = await Hive.openBox<RecordTypeModel>('recordTypes', path: dir.path);
    recordBox = await Hive.openBox<RecordModel>('records', path: dir.path);
  }

  // =========================
  // DOMAIN METHODS
  // =========================

  static Future<void> addDomain(String name) async {
    // Check if domain already exists
    final exists = domainBox.values.any((domain) => domain.name == name);
    if (exists) return;

    final domain = DomainModel()..name = name;
    await domainBox.add(domain);
  }

  static Future<List<DomainModel>> getAllDomains() async {
    return domainBox.values.toList();
  }

  // =========================
  // INSTITUTION METHODS
  // =========================

  static Future<void> addInstitution({
    required String name,
    required String domainName,
  }) async {
    final exists = institutionBox.values.any(
      (inst) => inst.name == name && inst.domainName == domainName,
    );
    if (exists) return;

    final institution = InstitutionModel()
      ..name = name
      ..domainName = domainName;

    await institutionBox.add(institution);
  }

  static Future<List<InstitutionModel>> getInstitutionsByDomain(
    String domainName,
  ) async {
    return institutionBox.values
        .where((inst) => inst.domainName == domainName)
        .toList();
  }

  static Future<List<InstitutionModel>> getAllInstitutions() async {
    final data = institutionBox.values.toList();
    // Sort by key in descending order
    data.sort((a, b) => b.key.compareTo(a.key));
    return data;
  }

  // =========================
  // RECORD TYPE METHODS
  // =========================

  static Future<void> addRecordType({
    required String name,
    required String institutionName,
    required String domainName,
  }) async {
    final exists = recordTypeBox.values.any(
      (rt) =>
          rt.name == name &&
          rt.institutionName == institutionName &&
          rt.domainName == domainName,
    );
    if (exists) return;

    final recordType = RecordTypeModel()
      ..name = name
      ..institutionName = institutionName
      ..domainName = domainName;

    await recordTypeBox.add(recordType);
  }

  static Future<List<RecordTypeModel>> getRecordTypes({
    required String domainName,
    required String institutionName,
  }) async {
    return recordTypeBox.values
        .where((rt) =>
            rt.domainName == domainName && rt.institutionName == institutionName)
        .toList();
  }

  static Future<List<RecordTypeModel>> getRecordTypesByInstitution(
    String institutionName,
  ) async {
    return recordTypeBox.values
        .where((rt) => rt.institutionName == institutionName)
        .toList();
  }

  // =========================
  // RECORD METHODS
  // =========================

  static Future<void> saveRecord(RecordModel record) async {
    final isNew = record.key == null;

    if (isNew) {
      await recordBox.add(record);
    } else {
      await record.save();
    }

    // Tracking for backup
    final prefs = await SharedPreferences.getInstance();

    if (isNew) {
      int count = prefs.getInt('new_records_count') ?? 0;
      await prefs.setInt('new_records_count', count + 1);
    }

    if (record.domainName.toUpperCase() == 'PERSONAL' ||
        record.domainName.toUpperCase() == 'FINANCE') {
      await prefs.setBool('sensitive_record_modified', true);
    }
  }

  static Future<List<RecordModel>> getRecords({
    required String domainName,
    required String institutionName,
    required String recordTypeName,
  }) async {
    return recordBox.values
        .where((record) =>
            record.domainName == domainName &&
            record.institutionName == institutionName &&
            record.recordTypeName == recordTypeName)
        .toList();
  }

  static Future<List<RecordModel>> getAllRecords() async {
    return recordBox.values.toList();
  }

  static Future<List<RecordModel>> getFavoriteRecords() async {
    return recordBox.values
        .where((record) => record.isFavorite == true)
        .toList();
  }

  static Future<int> getRecordCountByDomain(String domainName) async {
    return recordBox.values
        .where((record) => record.domainName == domainName)
        .length;
  }

  static Future<List<RecordModel>> searchRecords(String query) async {
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      return await getAllRecords();
    }

    return recordBox.values
        .where((record) => record.searchText.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static Future<List<RecordModel>> getExpiringRecords() async {
    final now = DateTime.now();
    final in15Days = now.add(const Duration(days: 15));

    return recordBox.values
        .where((record) =>
            record.expiryDate != null && record.expiryDate!.isBefore(in15Days))
        .toList();
  }

  // =========================
  // PASSWORD + BIOMETRIC
  // =========================

  static const String _passwordKey = 'master_password';
  static const String _biometricKey = 'biometric_enabled';
  static const String _privacyScreenKey = 'privacy_screen_enabled';

  static Future<bool> isPasswordSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_passwordKey);
  }

  static Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey) ?? '';
  }

  static Future<bool> verifyPassword(String password) async {
    if (!await isPasswordSet()) return false;

    final saved = await getPassword();
    return password.trim() == saved.trim();
  }

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final ok = await verifyPassword(currentPassword);
    if (!ok) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, newPassword);

    return true;
  }

  static Future<void> setNewPassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, newPassword);
  }

  static Future<void> resetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
  }

  static Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }

  static Future<bool> getPrivacyScreenEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyScreenKey) ?? true;
  }

  static Future<void> setPrivacyScreenEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyScreenKey, enabled);
  }

  // =========================
  // BACKUP TRACKING
  // =========================

  static Future<Map<String, dynamic>> getBackupStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final lastBackupStr = prefs.getString('last_backup_date');
    final lastBackup =
        lastBackupStr != null ? DateTime.parse(lastBackupStr) : null;
    final newRecordsCount = prefs.getInt('new_records_count') ?? 0;
    final sensitiveModified = prefs.getBool('sensitive_record_modified') ?? false;

    int daysSince = 0;
    if (lastBackup != null) {
      daysSince = DateTime.now().difference(lastBackup).inDays;
    } else {
      daysSince = 999; // Never backed up
    }

    return {
      'lastBackup': lastBackup,
      'daysSince': daysSince,
      'newRecords': newRecordsCount,
      'sensitiveModified': sensitiveModified,
    };
  }

  static Future<void> resetBackupTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_backup_date', DateTime.now().toIso8601String());
    await prefs.setInt('new_records_count', 0);
    await prefs.setBool('sensitive_record_modified', false);
  }

  // =========================
  // DELETE METHODS
  // =========================

  static Future<void> deleteDomain(dynamic id) async {
    final domain = domainBox.get(id);
    if (domain == null) return;

    final domainName = domain.name;

    // Delete records by domain
    final recordsToDelete = recordBox.values
        .where((record) => record.domainName == domainName)
        .toList();

    for (final record in recordsToDelete) {
      if (record.key != null) {
        await NotificationService.cancelNotification(record.key as int);
      }
      await record.delete();
    }

    // Delete record types by domain
    final recordTypesToDelete = recordTypeBox.values
        .where((rt) => rt.domainName == domainName)
        .toList();

    for (final rt in recordTypesToDelete) {
      await rt.delete();
    }

    // Delete institutions by domain
    final institutionsToDelete = institutionBox.values
        .where((inst) => inst.domainName == domainName)
        .toList();

    for (final inst in institutionsToDelete) {
      await inst.delete();
    }

    // Delete domain
    await domain.delete();
  }

  static Future<void> deleteInstitution(dynamic id) async {
    final institution = institutionBox.get(id);
    if (institution == null) return;

    final institutionName = institution.name;

    // Delete records by institution
    final recordsToDelete = recordBox.values
        .where((record) => record.institutionName == institutionName)
        .toList();

    for (final record in recordsToDelete) {
      if (record.key != null) {
        await NotificationService.cancelNotification(record.key as int);
      }
      await record.delete();
    }

    // Delete record types by institution
    final recordTypesToDelete = recordTypeBox.values
        .where((rt) => rt.institutionName == institutionName)
        .toList();

    for (final rt in recordTypesToDelete) {
      await rt.delete();
    }

    // Delete institution
    await institution.delete();
  }

  static Future<void> deleteRecordType(dynamic id) async {
    final recordType = recordTypeBox.get(id);
    if (recordType == null) return;

    final recordTypeName = recordType.name;

    // Delete records by record type
    final recordsToDelete = recordBox.values
        .where((record) => record.recordTypeName == recordTypeName)
        .toList();

    for (final record in recordsToDelete) {
      if (record.key != null) {
        await NotificationService.cancelNotification(record.key as int);
      }
      await record.delete();
    }

    // Delete record type
    await recordType.delete();
  }

  static Future<void> deleteRecord(dynamic id) async {
    if (id != null && id is int) {
      await NotificationService.cancelNotification(id);
    }
    final record = recordBox.get(id);
    if (record != null) {
      await record.delete();
    }
  }

  static Future<void> clearDatabase() async {
    await NotificationService.notifications.cancelAll();
    await domainBox.clear();
    await institutionBox.clear();
    await recordTypeBox.clear();
    await recordBox.clear();
  }
}
