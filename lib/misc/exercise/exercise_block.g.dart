// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseBlockAdapter extends TypeAdapter<ExerciseBlock> {
  @override
  final int typeId = 2;

  @override
  ExerciseBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseBlock(
      name: fields[0] as String,
      sets: fields[1] as int,
      reps: fields[2] as int,
      muscles: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseBlock obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.muscles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
