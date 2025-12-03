import 'package:hive_flutter/hive_flutter.dart';

// this file will be generated automatically when we run the build command
part 'workout_log.g.dart'; 

@HiveType(typeId: 2)
class WorkoutLog extends HiveObject {
  
  @HiveField(0)
  final String? id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final DateTime when;
  
  @HiveField(3)
  final int durationSec;
  
  @HiveField(4)
  final int totalKg;
  
  @HiveField(5)
  final String bestSet;
  
  @HiveField(6)
  final String setsDesc;
  
  @HiveField(7)
  final List<String> muscles;

  // --- NEW FIELDS FOR OFFLINE-FIRST (Matching Template.dart) ---
  @HiveField(8)
  final String syncStatus; // 'synced', 'pending', 'error'
  
  @HiveField(9)
  final int updatedAt;     // Timestamp for conflict resolution
  
  @HiveField(10)
  final bool isDeleted;    // Soft delete flag

  WorkoutLog({
    this.id,
    required this.title,
    required this.when,
    required this.durationSec,
    required this.totalKg,
    required this.bestSet,
    required this.setsDesc,
    required this.muscles,
    this.syncStatus = 'synced',
    this.updatedAt = 0,
    this.isDeleted = false,
  });

  WorkoutLog copyWith({
    String? id,
    String? title,
    DateTime? when,
    int? durationSec,
    int? totalKg,
    String? bestSet,
    String? setsDesc,
    List<String>? muscles,
    String? syncStatus,
    int? updatedAt,
    bool? isDeleted,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      title: title ?? this.title,
      when: when ?? this.when,
      durationSec: durationSec ?? this.durationSec,
      totalKg: totalKg ?? this.totalKg,
      bestSet: bestSet ?? this.bestSet,
      setsDesc: setsDesc ?? this.setsDesc,
      muscles: muscles ?? this.muscles,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'when': when.millisecondsSinceEpoch,
      'durationSec': durationSec,
      'totalKg': totalKg,
      'bestSet': bestSet,
      'setsDesc': setsDesc,
      'muscles': muscles,
      'syncStatus': syncStatus,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map, {String? id}) {
    final whenEpoch = map['when'] as int? ?? 0;
    
    return WorkoutLog(
      id: id,
      title: map['title'] as String? ?? '',
      when: DateTime.fromMillisecondsSinceEpoch(whenEpoch),
      durationSec: (map['durationSec'] as num?)?.toInt() ?? 0,
      totalKg: (map['totalKg'] as num?)?.toInt() ?? 0,
      bestSet: map['bestSet'] as String? ?? '-',
      setsDesc: map['setsDesc'] as String? ?? '',
      muscles: List<String>.from(map['muscles'] ?? []),
      syncStatus: map['syncStatus'] as String? ?? 'synced',
      updatedAt: (map['updatedAt'] as int?) ?? 0,
      isDeleted: (map['isDeleted'] as bool?) ?? false,
    );
  }
}