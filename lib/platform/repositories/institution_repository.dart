import 'package:bbeez_one/platform/models/institution_model.dart';

abstract class InstitutionRepository {
  Future<List<InstitutionModel>> getAll();
  Future<InstitutionModel?> getById(dynamic id);
  Future<void> save(InstitutionModel institution);
  Future<void> saveByName({
    required String name,
    required String domainName,
  });
  Future<List<InstitutionModel>> getByDomain(String domainName);
  Future<void> delete(dynamic id);
  Stream<List<InstitutionModel>> watchAll();
  Future<void> clear();
}
