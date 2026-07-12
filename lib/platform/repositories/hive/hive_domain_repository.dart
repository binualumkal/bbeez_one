import 'package:bbeez_one/platform/database/database_manager.dart';
import '../../models/domain_model.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';
import '../domain_repository.dart';
import '../institution_repository.dart';
import '../record_repository.dart';
import '../record_type_repository.dart';

class HiveDomainRepository implements DomainRepository {
  HiveDomainRepository({
    required DatabaseManager databaseManager,
    required InstitutionRepository institutionRepository,
    required RecordTypeRepository recordTypeRepository,
    required RecordRepository recordRepository,
  })  : _databaseManager = databaseManager,
        _institutionRepository = institutionRepository,
        _recordTypeRepository = recordTypeRepository,
        _recordRepository = recordRepository;

  final DatabaseManager _databaseManager;
  final InstitutionRepository _institutionRepository;
  final RecordTypeRepository _recordTypeRepository;
  final RecordRepository _recordRepository;

  @override
  Future<List<DomainModel>> getAll() async {
    final box = await _databaseManager.getDomainBox();
    return box.values.toList();
  }

  @override
  Future<DomainModel?> getById(dynamic id) async {
    final box = await _databaseManager.getDomainBox();
    return box.get(id);
  }

  @override
  Future<void> save(DomainModel domain) async {
    final box = await _databaseManager.getDomainBox();
    if (domain.key == null) {
      await box.add(domain);
    } else {
      await domain.save();
    }
  }

  @override
  Future<void> saveByName(String name) async {
    final box = await _databaseManager.getDomainBox();
    final exists = box.values.any((domain) => domain.name == name);
    if (exists) return;

    final domain = DomainModel()..name = name;
    await box.add(domain);
  }

  @override
  Future<void> delete(dynamic id) async {
    final domain = await getById(id);
    if (domain == null) return;

    final recordsToDelete = await _recordRepository.getAll();
    for (final record in recordsToDelete
        .where((record) => record.domainName == domain.name)) {
      if (record.key is int) {
        await NotificationService.cancelNotification(record.key as int);
      }
      await record.delete();
    }

    final recordTypesToDelete = await _recordTypeRepository.getAll();
    for (final recordType
        in recordTypesToDelete.where((rt) => rt.domainName == domain.name)) {
      await recordType.delete();
    }

    final institutionsToDelete = await _institutionRepository.getByDomain(
      domain.name,
    );
    for (final institution in institutionsToDelete) {
      await institution.delete();
    }

    await domain.delete();
  }

  @override
  Stream<List<DomainModel>> watchAll() async* {
    final box = await _databaseManager.getDomainBox();
    yield box.values.toList();
    yield* box.watch().map((_) => box.values.toList());
  }

  @override
  Future<void> clear() async {
    final box = await _databaseManager.getDomainBox();
    await box.clear();
  }
}
