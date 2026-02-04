// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p4_student_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentModelP4Adapter extends TypeAdapter<StudentModelP4> {
  @override
  final int typeId = 13;

  @override
  StudentModelP4 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentModelP4(
      studentName: fields[0] as String?,
      classIn: fields[1] as String?,
      contactNumber: fields[3] as String?,
      stream: fields[2] as String?,
      subjectsScore: (fields[4] as List).cast<P4Subjects>(),
      subjectsScoreTerm2: (fields[5] as List).cast<P4SubjectsTerm2>(),
      subjectsScoreTerm3: (fields[6] as List).cast<P4SubjectsTerm3>(),
     
      idNin: fields[8] as String?,
      id: fields[7] as int?,
     
      extraSub: (fields[9] as List?)?.cast<ExtraSubP4>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudentModelP4 obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.studentName)
      ..writeByte(1)
      ..write(obj.classIn)
      ..writeByte(2)
      ..write(obj.stream)
      ..writeByte(3)
      ..write(obj.contactNumber)
      ..writeByte(4)
      ..write(obj.subjectsScore)
      ..writeByte(5)
      ..write(obj.subjectsScoreTerm2)
      ..writeByte(6)
      ..write(obj.subjectsScoreTerm3)
      ..writeByte(7)
      ..write(obj.id)
      ..writeByte(8)
      ..write(obj.idNin)
      ..writeByte(9)
      ..write(obj.extraSub);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModelP4Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
