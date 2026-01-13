import 'exercise.dart';

abstract class ExerciseEvent {}

// Triggered when the app starts to load data from Hive
class LoadExercisesEvent extends ExerciseEvent {}

// Triggered when a user creates a new exercise
class AddExerciseEvent extends ExerciseEvent {
  final Exercise exercise;
  AddExerciseEvent(this.exercise);
}

// Triggered internally when Firebase sends new data
class SyncRemoteUpdatesEvent extends ExerciseEvent {
  final List<Exercise> remoteExercises;
  SyncRemoteUpdatesEvent(this.remoteExercises);
}

// Triggered to push pending local changes to Firebase
class TriggerSyncNowEvent extends ExerciseEvent {}