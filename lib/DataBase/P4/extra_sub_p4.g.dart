// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_sub_p4.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtraSubP4Adapter extends TypeAdapter<ExtraSubP4> {
  @override
  final int typeId = 72;

  @override
  ExtraSubP4 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtraSubP4(
      subjectName: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExtraSubP4 obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.subjectName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraSubP4Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
