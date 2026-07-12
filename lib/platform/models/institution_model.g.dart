// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'institution_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InstitutionModelAdapter extends TypeAdapter<InstitutionModel> {
  @override
  final int typeId = 1;

  @override
  InstitutionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstitutionModel()
      ..name = fields[0] as String
      ..domainName = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, InstitutionModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.domainName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstitutionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
