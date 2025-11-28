class WorkoutLog {
  final String title;
  final DateTime when;
  final int durationSec;
  final int totalKg;
  final String bestSet;
  final String setsDesc;
  final List<String> muscles;

  WorkoutLog({
    required this.title,
    required this.when,
    required this.durationSec,
    required this.totalKg,
    required this.bestSet,
    required this.setsDesc,
    required this.muscles,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'when': when.toIso8601String(),
      'durationSec': durationSec,
      'totalKg': totalKg,
      'bestSet': bestSet,
      'setsDesc': setsDesc,
      'muscles': muscles,
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> m) {
    return WorkoutLog(
      title: m['title'],
      when: DateTime.parse(m['when']),
      durationSec: m['durationSec'],
      totalKg: m['totalKg'],
      bestSet: m['bestSet'],
      setsDesc: m['setsDesc'],
      muscles: List<String>.from(m['muscles'] ?? []),
    );
  }
}
