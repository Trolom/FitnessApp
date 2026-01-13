import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'workout_log.dart';
import 'workout_event.dart';
import 'workout_state.dart';
import 'workout_service.dart';
import '../../content.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  StreamSubscription? _workoutSubscription;

  WorkoutBloc() : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<UpdateWorkouts>(_onUpdateWorkouts);
    on<AddWorkoutLog>(_onAddWorkoutLog);
  }

  void _onLoadWorkouts(LoadWorkouts event, Emitter<WorkoutState> emit) {
    emit(WorkoutLoading());
    _workoutSubscription?.cancel();
    
    _workoutSubscription = WorkoutService.streamWorkouts().listen((logs) {
      add(UpdateWorkouts(logs));
    });
  }

  void _onUpdateWorkouts(UpdateWorkouts event, Emitter<WorkoutState> emit) {
    final dayMap = _calculateMuscleWorkByDay(event.logs);
    final totals = _calculateTotalMuscleVolume(dayMap);

    emit(WorkoutLoaded(
      logs: event.logs,
      muscleWorkByDay: dayMap,
      totalMuscleVolume: totals,
    ));
  }

  Future<void> _onAddWorkoutLog(AddWorkoutLog event, Emitter<WorkoutState> emit) async {
    await WorkoutService.saveWorkout(event.log);
  }

  Map<DateTime, Map<String, int>> _calculateMuscleWorkByDay(List<WorkoutLog> workouts) {
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
  }

  Map<String, int> _calculateTotalMuscleVolume(Map<DateTime, Map<String, int>> dayMap) {
    final totals = <String, int>{};
    for (final dayEntry in dayMap.values) {
      for (final muscleEntry in dayEntry.entries) {
        totals[muscleEntry.key] = (totals[muscleEntry.key] ?? 0) + muscleEntry.value;
      }
    }
    return totals;
  }

  @override
  Future<void> close() {
    _workoutSubscription?.cancel();
    return super.close();
  }
}