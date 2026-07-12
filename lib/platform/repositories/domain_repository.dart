import 'package:bbeez_one/platform/models/domain_model.dart';

abstract class DomainRepository {
  Future<List<DomainModel>> getAll();
  Future<DomainModel?> getById(dynamic id);
  Future<void> save(DomainModel domain);
  Future<void> saveByName(String name);
  Future<void> delete(dynamic id);
  Stream<List<DomainModel>> watchAll();
  Future<void> clear();
}
