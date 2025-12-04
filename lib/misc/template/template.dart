import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../exercise/exercise_block.dart';

part 'template.g.dart';

@HiveType(typeId: 1)
class Template extends HiveObject {
  
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<ExerciseBlock> exercises;
  @HiveField(3)
  final bool isCustom;

  @HiveField(4, defaultValue: 'synced')
  final String syncStatus; 
  
  @HiveField(5, defaultValue: 0)
  final int updatedAt;     
  
  @HiveField(6, defaultValue: false)
  final bool isDeleted; 
  
  @HiveField(7, defaultValue: '')
  final String uid;

  Template({
    this.id,
    required this.name,
    required this.exercises,
    this.isCustom = false,
    this.syncStatus = 'synced',
    this.updatedAt = 0,
    this.isDeleted = false,
    required this.uid, // Required now
  });

  Template copyWith({
    String? id,
    String? name,
    List<ExerciseBlock>? exercises,
    bool? isCustom,
    String? syncStatus,
    int? updatedAt,
    bool? isDeleted,
    String? uid,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      isCustom: isCustom ?? this.isCustom,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCustom': isCustom,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'syncStatus': syncStatus,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'uid': uid,
    };
  }

  factory Template.fromMap(Map<String, dynamic> map, {String? id}) {
    return Template(
      id: id,
      name: (map['name'] as String?) ?? '',
      isCustom: (map['isCustom'] as bool?) ?? false,
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((e) => ExerciseBlock.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      syncStatus: (map['syncStatus'] as String?) ?? 'synced',
      updatedAt: (map['updatedAt'] as int?) ?? 0,
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      uid: map['uid'] as String? ?? '', // Read UID
    );
  }
  factory Template.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Template.fromMap(data, id: doc.id);
  }
}