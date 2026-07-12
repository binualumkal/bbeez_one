import 'package:hive/hive.dart';

part 'domain_model.g.dart';

@HiveType(typeId: 0)
class DomainModel extends HiveObject {
  @HiveField(0)
  late String name;
}
