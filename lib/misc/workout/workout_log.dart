class WorkoutLog {
  
  final String? id;
  final String title;
  final DateTime when;
  final int durationSec;
  final int totalKg;
  final String bestSet;
  final String setsDesc;
  final List<String> muscles;
  
  const WorkoutLog({
    this.id,
    required this.title,
    required this.when,
    required this.durationSec,
    required this.totalKg,
    required this.bestSet,
    required this.setsDesc,
    required this.muscles,
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
    );
  }
}