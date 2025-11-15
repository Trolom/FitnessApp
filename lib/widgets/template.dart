import 'exercise_block.dart';

class Template {
  final String name;
  final List<ExerciseBlock> exercises;
  final bool isCustom;

  const Template({
    required this.name,
    required this.exercises,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCustom': isCustom,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      name: map['name'] ?? '',
      isCustom: map['isCustom'] ?? false,
      exercises: (map['exercises'] as List)
          .map((e) => ExerciseBlock.fromMap(e))
          .toList(),
    );
  }
}
