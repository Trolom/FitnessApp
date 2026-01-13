import 'exercise.dart';

enum ExerciseStatus { initial, loading, success, error }

class ExerciseState {
  final List<Exercise> customExercises; // Only user-created ones
  final List<Exercise> allExercises;    // Combined Base + Custom
  final ExerciseStatus status;
  final String? errorMessage;

  ExerciseState({
    this.customExercises = const [],
    this.allExercises = const [],
    this.status = ExerciseStatus.initial,
    this.errorMessage,
  });

  ExerciseState copyWith({
    List<Exercise>? customExercises,
    List<Exercise>? allExercises,
    ExerciseStatus? status,
    String? errorMessage,
  }) {
    return ExerciseState(
      customExercises: customExercises ?? this.customExercises,
      allExercises: allExercises ?? this.allExercises,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}