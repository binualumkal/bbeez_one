import 'package:bbeez_one/platform/models/record_type_model.dart';

abstract class RecordTypeRepository {
  Future<List<RecordTypeModel>> getAll();
  Future<RecordTypeModel?> getById(dynamic id);
  Future<void> save(RecordTypeModel recordType);
  Future<void> saveByName({
    required String name,
    required String institutionName,
    required String domainName,
  });
  Future<List<RecordTypeModel>> getByDomainAndInstitution({
    required String domainName,
    required String institutionName,
  });
  Future<List<RecordTypeModel>> getByInstitution(String institutionName);
  Future<void> delete(dynamic id);
  Stream<List<RecordTypeModel>> watchAll();
  Future<void> clear();
}
