import 'package:hive_flutter/hive_flutter.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 3)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int heightCm;

  @HiveField(3)
  final double weightKg;

  @HiveField(4)
  final double? goalWeightKg;

  @HiveField(5)
  final String? profileImageUrl;

  // Sync Metadata
  @HiveField(6)
  final String syncStatus;
  
  @HiveField(7)
  final int updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    this.heightCm = 0,
    this.weightKg = 0.0,
    this.goalWeightKg,
    this.profileImageUrl,
    this.syncStatus = 'synced',
    this.updatedAt = 0,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    int? heightCm,
    double? weightKg,
    double? goalWeightKg,
    String? profileImageUrl,
    String? syncStatus,
    int? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goalWeightKg': goalWeightKg,
      'profileImageUrl': profileImageUrl,
      'syncStatus': syncStatus,
      'updatedAt': updatedAt,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?) ?? 'User',
      heightCm: (map['heightCm'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      goalWeightKg: (map['goalWeightKg'] as num?)?.toDouble(),
      profileImageUrl: (map['profileImageUrl'] as String?),
      syncStatus: (map['syncStatus'] as String?) ?? 'synced',
      updatedAt: (map['updatedAt'] as int?) ?? 0,
    );
  }
}