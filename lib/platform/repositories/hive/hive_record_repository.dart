import 'dart:async';

import 'package:bbeez_one/platform/database/database_manager.dart';
import '../../models/record_model.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';
import '../record_repository.dart';
import '../settings_repository.dart';

class HiveRecordRepository implements RecordRepository {
  HiveRecordRepository({
    required DatabaseManager databaseManager,
    required SettingsRepository settingsRepository,
  })  : _databaseManager = databaseManager,
        _settingsRepository = settingsRepository;

  final DatabaseManager _databaseManager;
  final SettingsRepository _settingsRepository;

  @override
  Future<List<RecordModel>> getAll() async {
    final box = await _databaseManager.getRecordBox();
    return box.values.toList();
  }

  @override
  Future<RecordModel?> getById(dynamic id) async {
    final box = await _databaseManager.getRecordBox();
    return box.get(id);
  }

  @override
  Future<void> save(RecordModel record) async {
    final box = await _databaseManager.getRecordBox();
    final isNew = record.key == null;

    if (isNew) {
      await box.add(record);
    } else {
      await record.save();
    }

    await _settingsRepository.trackRecordSaved(
      isNew: isNew,
      domainName: record.domainName,
    );
  }

  @override
  Future<void> saveImported(RecordModel record) async {
    final box = await _databaseManager.getRecordBox();
    await box.add(record);
  }

  @override
  Future<List<RecordModel>> getByContext({
    required String domainName,
    required String institutionName,
    required String recordTypeName,
  }) async {
    final box = await _databaseManager.getRecordBox();
    return box.values
        .where((record) =>
            record.domainName == domainName &&
            record.institutionName == institutionName &&
            record.recordTypeName == recordTypeName)
        .toList();
  }

  @override
  Future<List<RecordModel>> getFavorites() async {
    final box = await _databaseManager.getRecordBox();
    return box.values.where((record) => record.isFavorite).toList();
  }

  @override
  Future<int> getCountByDomain(String domainName) async {
    final box = await _databaseManager.getRecordBox();
    return box.values.where((record) => record.domainName == domainName).length;
  }

  @override
  Future<List<RecordModel>> search(String query) async {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) {
      return getAll();
    }

    final box = await _databaseManager.getRecordBox();
    return box.values
        .where((record) => record.searchText.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<List<RecordModel>> getExpiring() async {
    final now = DateTime.now();
    final in15Days = now.add(const Duration(days: 15));
    final box = await _databaseManager.getRecordBox();

    return box.values
        .where(
          (record) =>
              record.expiryDate != null &&
              record.expiryDate!.isBefore(in15Days),
        )
        .toList();
  }

  @override
  Future<void> delete(dynamic id) async {
    if (id is int) {
      await NotificationService.cancelNotification(id);
    }

    final record = await getById(id);
    if (record != null) {
      await record.delete();
    }
  }

  @override
  Stream<List<RecordModel>> watchAll() async* {
    final box = await _databaseManager.getRecordBox();
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  @override
  Future<void> clear() async {
    final box = await _databaseManager.getRecordBox();
    await box.clear();
  }
}
