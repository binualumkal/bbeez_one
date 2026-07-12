import 'package:bbeez_one/platform/database/database_manager.dart';
import '../../models/record_type_model.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';
import '../record_repository.dart';
import '../record_type_repository.dart';

class HiveRecordTypeRepository implements RecordTypeRepository {
  HiveRecordTypeRepository({
    required DatabaseManager databaseManager,
    required RecordRepository recordRepository,
  })  : _databaseManager = databaseManager,
        _recordRepository = recordRepository;

  final DatabaseManager _databaseManager;
  final RecordRepository _recordRepository;

  @override
  Future<List<RecordTypeModel>> getAll() async {
    final box = await _databaseManager.getRecordTypeBox();
    return box.values.toList();
  }

  @override
  Future<RecordTypeModel?> getById(dynamic id) async {
    final box = await _databaseManager.getRecordTypeBox();
    return box.get(id);
  }

  @override
  Future<void> save(RecordTypeModel recordType) async {
    final box = await _databaseManager.getRecordTypeBox();
    if (recordType.key == null) {
      await box.add(recordType);
    } else {
      await recordType.save();
    }
  }

  @override
  Future<void> saveByName({
    required String name,
    required String institutionName,
    required String domainName,
  }) async {
    final box = await _databaseManager.getRecordTypeBox();
    final exists = box.values.any(
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
    await box.add(recordType);
  }

  @override
  Future<List<RecordTypeModel>> getByDomainAndInstitution({
    required String domainName,
    required String institutionName,
  }) async {
    final box = await _databaseManager.getRecordTypeBox();
    return box.values
        .where(
          (rt) =>
              rt.domainName == domainName &&
              rt.institutionName == institutionName,
        )
        .toList();
  }

  @override
  Future<List<RecordTypeModel>> getByInstitution(String institutionName) async {
    final box = await _databaseManager.getRecordTypeBox();
    return box.values
        .where((rt) => rt.institutionName == institutionName)
        .toList();
  }

  @override
  Future<void> delete(dynamic id) async {
    final recordType = await getById(id);
    if (recordType == null) return;

    final recordsToDelete = await _recordRepository.getAll();
    for (final record in recordsToDelete
        .where((record) => record.recordTypeName == recordType.name)) {
      if (record.key is int) {
        await NotificationService.cancelNotification(record.key as int);
      }
      await record.delete();
    }

    await recordType.delete();
  }

  @override
  Stream<List<RecordTypeModel>> watchAll() async* {
    final box = await _databaseManager.getRecordTypeBox();
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  @override
  Future<void> clear() async {
    final box = await _databaseManager.getRecordTypeBox();
    await box.clear();
  }
}
