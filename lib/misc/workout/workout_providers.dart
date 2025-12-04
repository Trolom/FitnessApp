import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'workout_log.dart';
import 'workout_service.dart';
import '../../content.dart'; 
// this stream tracks who is logged in.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final workoutLogsProvider = StreamProvider<List<WorkoutLog>>((ref) {
  ref.watch(authStateProvider);
  
  return WorkoutService.streamWorkouts();
});

class WorkoutController {
  final Ref ref;
  WorkoutController(this.ref);

  Future<void> addLog(WorkoutLog log) async {
    await WorkoutService.saveWorkout(log);
  }

  Future<void> syncPending() async {
    await WorkoutService.syncPendingWorkouts();
  }
}

final workoutControllerProvider = Provider((ref) => WorkoutController(ref));


final muscleWorkByDayProvider = Provider<Map<DateTime, Map<String, int>>>((ref) {
  final workoutsAsync = ref.watch(workoutLogsProvider);
  
  return workoutsAsync.when(
    data: (workouts) {
      final result = <DateTime, Map<String, int>>{};

      for (final w in workouts) {
        if (w.isDeleted) continue;

        final dayKey = DateTime(w.when.year, w.when.month, w.when.day);
        result.putIfAbsent(dayKey, () => {});

        for (final rawMuscle in w.muscles) {
          final group = muscleToGroup[rawMuscle]; 
          if (group == null) continue;
          
          result[dayKey]![group] = (result[dayKey]![group] ?? 0) + 1;
        }
      }
      return result;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

final totalMuscleVolumeProvider = Provider<Map<String, int>>((ref) {
  final dayMap = ref.watch(muscleWorkByDayProvider);
  
  final totals = <String, int>{};
  for (final dayEntry in dayMap.values) {
    for (final muscleEntry in dayEntry.entries) {
      totals[muscleEntry.key] =
          (totals[muscleEntry.key] ?? 0) + muscleEntry.value;
    }
  }
  return totals;
});