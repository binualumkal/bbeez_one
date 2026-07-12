import 'package:hive/hive.dart';

import 'secret_field_model.dart';

part 'record_model.g.dart';

@HiveType(typeId: 3)
class RecordModel extends HiveObject {

  @HiveField(0)
  late String domainName;

  @HiveField(1)
  late String institutionName;

  @HiveField(2)
  late String recordTypeName;

  @HiveField(3)
  List<SecretField> fields = [];

  @HiveField(4)
  late String searchText;

  @HiveField(5)
  bool isFavorite = false;

  @HiveField(6)
  DateTime? expiryDate;
}