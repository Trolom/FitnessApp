class Exercise {
  final String name;
  final String muscles; // example: "Chest • Shoulders • Triceps"
  final int sets;
  final int reps;
  final String unit; // "reps" or "sec"
  final bool isCustom; // true = created by user

  const Exercise({
    required this.name,
    required this.muscles,
    required this.sets,
    required this.reps,
    this.unit = 'reps',
    this.isCustom = false,
  });

  // Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscles': muscles,
      'sets': sets,
      'reps': reps,
      'unit': unit,
      'isCustom': isCustom,
    };
  }

  // Convert Firestore → Exercise
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'],
      muscles: map['muscles'],
      sets: map['sets'],
      reps: map['reps'],
      unit: map['unit'] ?? 'reps',
      isCustom: map['isCustom'] ?? false,
    );
  }
}
