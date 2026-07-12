import 'package:hive/hive.dart';

part 'secret_field_model.g.dart';

@HiveType(typeId: 4)
class SecretField {
  @HiveField(0)
  late String label;

  @HiveField(1)
  String? value;

  @HiveField(2)
  String? value2;

  @HiveField(3)
  bool isHidden = true;
}
