// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_field_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecretFieldAdapter extends TypeAdapter<SecretField> {
  @override
  final int typeId = 4;

  @override
  SecretField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecretField()
      ..label = fields[0] as String
      ..value = fields[1] as String?
      ..value2 = fields[2] as String?
      ..isHidden = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, SecretField obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.value2)
      ..writeByte(3)
      ..write(obj.isHidden);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
