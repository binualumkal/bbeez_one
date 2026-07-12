import 'package:hive/hive.dart';

part 'record_type_model.g.dart';

@HiveType(typeId: 2)
class RecordTypeModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String institutionName;

  @HiveField(2)
  late String domainName;
}
