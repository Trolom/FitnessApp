import 'workout_log.dart';

class WorkoutState {
  final List<WorkoutLog> logs;
  final Map<DateTime, Map<String, int>> muscleWorkByDay;
  final Map<String, int> totalMuscleVolume;
  final bool isLoading;

  WorkoutState({
    this.logs = const [],
    this.muscleWorkByDay = const {},
    this.totalMuscleVolume = const {},
    this.isLoading = true, // Default to true so UI shows a loader initially
  });

  // This is crucial for updating the state without losing other values
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