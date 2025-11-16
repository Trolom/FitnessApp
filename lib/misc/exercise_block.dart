class ExerciseBlock {
  final String name;
  final int sets;
  final int reps;
  final List<String> muscles;  // ADD

  const ExerciseBlock({
    required this.name,
    required this.sets,
    required this.reps,
    required this.muscles,     // ADD
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'muscles': muscles,       // ADD
    };
  }

  factory ExerciseBlock.fromMap(Map<String, dynamic> map) {
    return ExerciseBlock(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      muscles: List<String>.from(map['muscles'] ?? []), // ADD
    );
  }
}
