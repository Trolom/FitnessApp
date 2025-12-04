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
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?) ?? 'User',
      heightCm: _parseInt(map['heightCm']),
      weightKg: _parseDouble(map['weightKg']),
      goalWeightKg: map['goalWeightKg'] != null ? _parseDouble(map['goalWeightKg']) : null,
      profileImageUrl: (map['profileImageUrl'] as String?),
      syncStatus: (map['syncStatus'] as String?) ?? 'synced',
      updatedAt: _parseInt(map['updatedAt']),
    );
  }
}