import 'package:hive_flutter/hive_flutter.dart';

part 'workout_log.g.dart'; 

@HiveType(typeId: 10)
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

  @HiveField(8)
  final String syncStatus; 
  
  @HiveField(9)
  final int updatedAt;
  
  @HiveField(10)
  final bool isDeleted;

  @HiveField(11, defaultValue: '')
  final String uid; 

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
    required this.uid,
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
    String? uid,
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
      uid: uid ?? this.uid,
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
      'uid': uid,
    };
  }
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  factory WorkoutLog.fromMap(Map<String, dynamic> map, {String? id}) {
    int whenEpoch = 0;
    if (map['when'] != null) {
      whenEpoch = _parseInt(map['when']);
    }
    
    return WorkoutLog(
      id: id,
      title: map['title'] as String? ?? '',
      when: DateTime.fromMillisecondsSinceEpoch(whenEpoch),
      // to handle String or Int safely
      durationSec: _parseInt(map['durationSec']),
      totalKg: _parseInt(map['totalKg']),
      bestSet: map['bestSet'] as String? ?? '-',
      setsDesc: map['setsDesc'] as String? ?? '',
      muscles: List<String>.from(map['muscles'] ?? []),
      syncStatus: map['syncStatus'] as String? ?? 'synced',
      updatedAt: _parseInt(map['updatedAt']),
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      uid: map['uid'] as String? ?? '',
    );
  }
}