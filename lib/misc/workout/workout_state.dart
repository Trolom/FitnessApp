import 'package:equatable/equatable.dart';
import 'workout_log.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();
  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<WorkoutLog> logs;
  final Map<DateTime, Map<String, int>> muscleWorkByDay;
  final Map<String, int> totalMuscleVolume;

  const WorkoutLoaded({
    required this.logs,
    required this.muscleWorkByDay,
    required this.totalMuscleVolume,
  });

  @override
  List<Object?> get props => [logs, muscleWorkByDay, totalMuscleVolume];
}

class WorkoutError extends WorkoutState {
  final String message;
  const WorkoutError(this.message);
}