// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 3;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      uid: fields[0] as String,
      name: fields[1] as String,
      heightCm: fields[2] as int,
      weightKg: fields[3] as double,
      goalWeightKg: fields[4] as double?,
      profileImageUrl: fields[5] as String?,
      syncStatus: fields[6] as String,
      updatedAt: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.heightCm)
      ..writeByte(3)
      ..write(obj.weightKg)
      ..writeByte(4)
      ..write(obj.goalWeightKg)
      ..writeByte(5)
      ..write(obj.profileImageUrl)
      ..writeByte(6)
      ..write(obj.syncStatus)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
