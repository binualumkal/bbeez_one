import 'package:bbeez_one/platform/database/database_manager.dart';
import '../../models/institution_model.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';
import '../institution_repository.dart';
import '../record_repository.dart';
import '../record_type_repository.dart';

class HiveInstitutionRepository implements InstitutionRepository {
  HiveInstitutionRepository({
    required DatabaseManager databaseManager,
    required RecordTypeRepository recordTypeRepository,
    required RecordRepository recordRepository,
  })  : _databaseManager = databaseManager,
        _recordTypeRepository = recordTypeRepository,
        _recordRepository = recordRepository;

  final DatabaseManager _databaseManager;
  final RecordTypeRepository _recordTypeRepository;
  final RecordRepository _recordRepository;

  @override
  Future<List<InstitutionModel>> getAll() async {
    final box = await _databaseManager.getInstitutionBox();
    final data = box.values.toList();
    data.sort((a, b) => b.key.compareTo(a.key));
    return data;
  }

  @override
  Future<InstitutionModel?> getById(dynamic id) async {
    final box = await _databaseManager.getInstitutionBox();
    return box.get(id);
  }

  @override
  Future<void> save(InstitutionModel institution) async {
    final box = await _databaseManager.getInstitutionBox();
    if (institution.key == null) {
      await box.add(institution);
    } else {
      await institution.save();
    }
  }

  @override
  Future<void> saveByName({
    required String name,
    required String domainName,
  }) async {
    final box = await _databaseManager.getInstitutionBox();
    final exists = box.values.any(
      (inst) => inst.name == name && inst.domainName == domainName,
    );
    if (exists) return;

    final institution = InstitutionModel()
      ..name = name
      ..domainName = domainName;
    await box.add(institution);
  }

  @override
  Future<List<InstitutionModel>> getByDomain(String domainName) async {
    final box = await _databaseManager.getInstitutionBox();
    return box.values.where((inst) => inst.domainName == domainName).toList();
  }

  @override
  Future<void> delete(dynamic id) async {
    final institution = await getById(id);
    if (institution == null) return;

    final recordsToDelete = await _recordRepository.getAll();
    for (final record in recordsToDelete
        .where((record) => record.institutionName == institution.name)) {
      if (record.key is int) {
        await NotificationService.cancelNotification(record.key as int);
      }
      await record.delete();
    }

    final recordTypesToDelete = await _recordTypeRepository.getByInstitution(
      institution.name,
    );
    for (final recordType in recordTypesToDelete) {
      await recordType.delete();
    }

    await institution.delete();
  }

  @override
  Stream<List<InstitutionModel>> watchAll() async* {
    final box = await _databaseManager.getInstitutionBox();
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  @override
  Future<void> clear() async {
    final box = await _databaseManager.getInstitutionBox();
    await box.clear();
  }
}
