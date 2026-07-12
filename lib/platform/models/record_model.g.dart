// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordModelAdapter extends TypeAdapter<RecordModel> {
  @override
  final int typeId = 3;

  @override
  RecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordModel()
      ..domainName = fields[0] as String
      ..institutionName = fields[1] as String
      ..recordTypeName = fields[2] as String
      ..fields = (fields[3] as List).cast<SecretField>()
      ..searchText = fields[4] as String
      ..isFavorite = fields[5] as bool
      ..expiryDate = fields[6] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, RecordModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.domainName)
      ..writeByte(1)
      ..write(obj.institutionName)
      ..writeByte(2)
      ..write(obj.recordTypeName)
      ..writeByte(3)
      ..write(obj.fields)
      ..writeByte(4)
      ..write(obj.searchText)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.expiryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
