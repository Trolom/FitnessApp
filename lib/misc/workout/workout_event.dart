import 'package:equatable/equatable.dart';
import 'workout_log.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the app starts or a user logs in
class LoadWorkouts extends WorkoutEvent {}

/// Triggered when a user finishes a workout and saves it
class AddWorkoutLog extends WorkoutEvent {
  final WorkoutLog log;

  const AddWorkoutLog(this.log);

  @override
  List<Object?> get props => [log];
}

/// Triggered internally by the Bloc when the WorkoutService 
/// emits new data from Hive or Firebase
class UpdateWorkouts extends WorkoutEvent {
  final List<WorkoutLog> logs;

  const UpdateWorkouts(this.logs);

  @override
  List<Object?> get props => [logs];
}