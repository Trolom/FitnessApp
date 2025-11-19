import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_block.dart';

class Template {
  final String? id;
  final String name;
  final List<ExerciseBlock> exercises;
  final bool isCustom;

  const Template({
    this.id,
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

  // Use this when reading from Firestore so we also capture doc.id.
  factory Template.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Template(
      id: doc.id, // keep the id for delete/edit
      name: (data['name'] as String?) ?? '',
      isCustom: (data['isCustom'] as bool?) ?? false,
      exercises: (data['exercises'] as List<dynamic>? ?? [])
          .map((e) => ExerciseBlock.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  // kept for backward compatibility
  // prefer `fromDoc` so you don't lose the id
  factory Template.fromMap(Map<String, dynamic> map, {String? id}) {
    return Template(
      id: id, // optional
      name: (map['name'] as String?) ?? '',
      isCustom: (map['isCustom'] as bool?) ?? false,
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((e) => ExerciseBlock.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}