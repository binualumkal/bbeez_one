// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordTypeModelAdapter extends TypeAdapter<RecordTypeModel> {
  @override
  final int typeId = 2;

  @override
  RecordTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordTypeModel()
      ..name = fields[0] as String
      ..institutionName = fields[1] as String
      ..domainName = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, RecordTypeModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.institutionName)
      ..writeByte(2)
      ..write(obj.domainName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
