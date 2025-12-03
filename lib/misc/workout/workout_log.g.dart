// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogAdapter extends TypeAdapter<WorkoutLog> {
  @override
  final int typeId = 2;

  @override
  WorkoutLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLog(
      id: fields[0] as String?,
      title: fields[1] as String,
      when: fields[2] as DateTime,
      durationSec: fields[3] as int,
      totalKg: fields[4] as int,
      bestSet: fields[5] as String,
      setsDesc: fields[6] as String,
      muscles: (fields[7] as List).cast<String>(),
      syncStatus: fields[8] as String,
      updatedAt: fields[9] as int,
      isDeleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLog obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.when)
      ..writeByte(3)
      ..write(obj.durationSec)
      ..writeByte(4)
      ..write(obj.totalKg)
      ..writeByte(5)
      ..write(obj.bestSet)
      ..writeByte(6)
      ..write(obj.setsDesc)
      ..writeByte(7)
      ..write(obj.muscles)
      ..writeByte(8)
      ..write(obj.syncStatus)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
