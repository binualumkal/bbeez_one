import 'package:hive/hive.dart';

part 'institution_model.g.dart';

@HiveType(typeId: 1)
class InstitutionModel extends HiveObject {

  @HiveField(0)
  late String name;

  @HiveField(1)
  late String domainName;
}