class ExerciseBlock {
  final String name;
  final int sets;
  final int reps;

  const ExerciseBlock({
    required this.name,
    required this.sets,
    required this.reps,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
    };
  }

  factory ExerciseBlock.fromMap(Map<String, dynamic> map) {
    return ExerciseBlock(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
    );
  }
}
