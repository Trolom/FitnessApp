import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'workout_log.dart';
import 'workout_service.dart';
import '../../local_db.dart';
import '../../content.dart';

const _uuid = Uuid();


class WorkoutSyncManager {
  final Ref ref;

  WorkoutSyncManager(this.ref) {
    // listens to firebase stream and update local DB when changes happen
    ref.listen(remoteWorkoutsStreamProvider, (_, next) {
      next.whenData((remoteList) {
        _handleRemoteUpdates(remoteList);
      });
    });
  }

  // psuh offline items to firebase
  Future<void> syncNow() async {
    debugPrint("Workout Sync: Starting.");
    final pending = await localDbService.getPendingWorkouts();

    for (final log in pending) {
      try {
        await WorkoutService.saveWorkout(log);
        
        // if sucesfull, mark as synced locally
        final syncedLog = log.copyWith(syncStatus: 'synced');
        ref.read(workoutLogsProvider.notifier).updateSynced(syncedLog);
        
        debugPrint("Workout Sync: Uploaded ${log.title}");
      } catch (e) {
        debugPrint('Workout Sync failed for ${log.title}: $e');
      }
    }
  }

  // merging the firebase data into Local DB
  void _handleRemoteUpdates(List<WorkoutLog> remoteList) {
    final localList = ref.read(workoutLogsProvider).value ?? [];

    for (final remoteLog in remoteList) {
      WorkoutLog? localLog;
      try {
        localLog = localList.firstWhere((e) => e.id == remoteLog.id);
      } catch (e) {

      }

      if (localLog == null || remoteLog.updatedAt > localLog.updatedAt) {
        ref.read(workoutLogsProvider.notifier).updateSynced(remoteLog.copyWith(syncStatus: 'synced'));
      }
    }
  }
}

final workoutSyncManagerProvider = Provider((ref) => WorkoutSyncManager(ref));

final remoteWorkoutsStreamProvider = StreamProvider<List<WorkoutLog>>((ref) {
  return WorkoutService.streamWorkouts();
});

// UI listens to this, not firebase directly
class WorkoutLogsNotifier extends AsyncNotifier<List<WorkoutLog>> {
  
  @override
  Future<List<WorkoutLog>> build() async {
    ref.read(workoutSyncManagerProvider); 
    return localDbService.getAllWorkouts();
  }

  Future<void> addLog(WorkoutLog log) async {
    final newId = _uuid.v4();
    
    final newLog = log.copyWith(
      id: newId,
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await localDbService.saveWorkout(newLog);

    final currentList = state.value ?? [];
    final newList = [...currentList, newLog]
      ..sort((a, b) => b.when.compareTo(a.when));
    
    state = AsyncData(newList);

    ref.read(workoutSyncManagerProvider).syncNow();
  }

  void updateSynced(WorkoutLog syncedLog) {
    if (state.value == null) return;

    final currentList = state.value!;
    // check if it exists, replace it; otherwise add it
    final index = currentList.indexWhere((e) => e.id == syncedLog.id);
    
    List<WorkoutLog> newList;
    if (index >= 0) {
      newList = List.from(currentList);
      newList[index] = syncedLog;
    } else {
      newList = [...currentList, syncedLog];
    }

    //to sort
    newList.sort((a, b) => b.when.compareTo(a.when));

    state = AsyncData(newList);
    localDbService.saveWorkout(syncedLog);
  }
}

final workoutLogsProvider = AsyncNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>(() => WorkoutLogsNotifier());


final muscleWorkByDayProvider = Provider<Map<DateTime, Map<String, int>>>((ref) {
  final workoutsAsync = ref.watch(workoutLogsProvider);
  
  return workoutsAsync.maybeWhen(
    data: (workouts) {
      final result = <DateTime, Map<String, int>>{};

      for (final w in workouts) {
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
    orElse: () => {},
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