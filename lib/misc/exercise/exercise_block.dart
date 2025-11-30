// exercise_block.dart

import 'package:hive_flutter/hive_flutter.dart';

part 'exercise_block.g.dart';

@HiveType(typeId: 2)
class ExerciseBlock extends HiveObject {
  
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int sets;
  @HiveField(2)
  final int reps;
  @HiveField(3)
  final List<String> muscles;  

  ExerciseBlock({
    required this.name,
    required this.sets,
    required this.reps,
    required this.muscles,     
  });
  

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'muscles': muscles,
    };
  }

  factory ExerciseBlock.fromMap(Map<String, dynamic> map) {
    return ExerciseBlock(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      muscles: List<String>.from(map['muscles'] ?? []),
    );
  }
}