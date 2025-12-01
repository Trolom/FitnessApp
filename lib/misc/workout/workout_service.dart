import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../content.dart';
import 'workout_log.dart';

class WorkoutService {
  static final _db = FirebaseFirestore.instance;
  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<void> saveWorkout(WorkoutLog log) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .add(log.toMap());
  }

  static Stream<List<WorkoutLog>> streamWorkouts() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('when', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => WorkoutLog.fromMap(d.data())).toList());
  }

  static Stream<Map<DateTime, Map<String, int>>> muscleWorkByDayStream() {
    return streamWorkouts().map((workouts) {
      final result = <DateTime, Map<String, int>>{};

      for (final w in workouts) {
        final dayKey = DateTime(w.when.year, w.when.month, w.when.day);
        result.putIfAbsent(dayKey, () => {});

        for (final rawMuscle in w.muscles) {

          final group = muscleToGroup[rawMuscle] ?? null;
          if (group == null) continue;

          result[dayKey]![group] = (result[dayKey]![group] ?? 0) + 1;
        }
      }

      return result;
    });
  }

  static Stream<Map<String, int>> totalMuscleVolumeStream() {
    return muscleWorkByDayStream().map((dayMap) {
      final totals = <String, int>{};

      for (final dayEntry in dayMap.values) {
        for (final muscleEntry in dayEntry.entries) {
          totals[muscleEntry.key] =
              (totals[muscleEntry.key] ?? 0) + muscleEntry.value;
        }
      }

      return totals;
    });
  }
}

  