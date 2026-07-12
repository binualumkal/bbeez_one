// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DomainModelAdapter extends TypeAdapter<DomainModel> {
  @override
  final int typeId = 0;

  @override
  DomainModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DomainModel()..name = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, DomainModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
