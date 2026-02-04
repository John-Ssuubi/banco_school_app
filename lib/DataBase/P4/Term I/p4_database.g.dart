// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p4_database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class P4SubjectsAdapter extends TypeAdapter<P4Subjects> {
  @override
  final int typeId = 7;

  @override
  P4Subjects read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return P4Subjects(
      subjectName: fields[0] as String,
      scoreBOT: fields[1] as double,
      scoreEOT: fields[2] as double,
      scoreMT: fields[3] as double,
      teacher: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, P4Subjects obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.subjectName)
      ..writeByte(1)
      ..write(obj.scoreBOT)
      ..writeByte(2)
      ..write(obj.scoreEOT)
      ..writeByte(3)
      ..write(obj.scoreMT)
      ..writeByte(4)
      ..write(obj.teacher);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is P4SubjectsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
