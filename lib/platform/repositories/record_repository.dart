import 'package:bbeez_one/platform/models/record_model.dart';

abstract class RecordRepository {
  Future<List<RecordModel>> getAll();
  Future<RecordModel?> getById(dynamic id);
  Future<void> save(RecordModel record);
  Future<void> saveImported(RecordModel record);
  Future<List<RecordModel>> getByContext({
    required String domainName,
    required String institutionName,
    required String recordTypeName,
  });
  Future<List<RecordModel>> getFavorites();
  Future<int> getCountByDomain(String domainName);
  Future<List<RecordModel>> search(String query);
  Future<List<RecordModel>> getExpiring();
  Future<void> delete(dynamic id);
  Stream<List<RecordModel>> watchAll();
  Future<void> clear();
}
