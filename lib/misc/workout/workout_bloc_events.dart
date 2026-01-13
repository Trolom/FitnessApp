import 'workout_log.dart';

abstract class WorkoutEvent {}

class InitializeWorkoutSubscription extends WorkoutEvent {}

class AddWorkoutLog extends WorkoutEvent {
  final WorkoutLog log;
  AddWorkoutLog(this.log);
}

class RequestSync extends WorkoutEvent {}

class UpdateWorkoutList extends WorkoutEvent {
  final List<WorkoutLog> logs;
  UpdateWorkoutList(this.logs);
}

// workout_state.dart
class WorkoutState {
  final List<WorkoutLog> logs;
  final Map<DateTime, Map<String, int>> muscleWorkByDay;
  final Map<String, int> totalMuscleVolume;
  final bool isLoading;

  WorkoutState({
    this.logs = const [],
    this.muscleWorkByDay = const {},
    this.totalMuscleVolume = const {},
    this.isLoading = true,
  });

  WorkoutState copyWith({
    List<WorkoutLog>? logs,
    Map<DateTime, Map<String, int>>? muscleWorkByDay,
    Map<String, int>? totalMuscleVolume,
    bool? isLoading,
  }) {
    return WorkoutState(
      logs: logs ?? this.logs,
      muscleWorkByDay: muscleWorkByDay ?? this.muscleWorkByDay,
      totalMuscleVolume: totalMuscleVolume ?? this.totalMuscleVolume,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}