import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'misc/exercise/exercise.dart';
import 'misc/template/template.dart';
import 'misc/exercise/exercise_block.dart';
import 'misc/user/user_profile.dart';
import 'misc/workout/workout_log.dart';

const String _exerciseBoxName = 'exercises';
const String _templateBoxName = 'templates';
const String _profileBoxName = 'user_profile';
const String _workoutBoxName = 'workouts';

class LocalDbService {
  
  late Box<Exercise> _exerciseBox;
  late Box<Template> _templateBox;
  late Box<UserProfile> _profileBox;
  late Box<WorkoutLog> _workoutBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(ExerciseAdapter().typeId)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(ExerciseBlockAdapter().typeId)) {
      Hive.registerAdapter(ExerciseBlockAdapter());
    }
    if (!Hive.isAdapterRegistered(TemplateAdapter().typeId)) {
      Hive.registerAdapter(TemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(UserProfileAdapter().typeId)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutLogAdapter().typeId)) {
      Hive.registerAdapter(WorkoutLogAdapter());
    }
    
    _exerciseBox = await Hive.openBox<Exercise>(_exerciseBoxName);
    _templateBox = await Hive.openBox<Template>(_templateBoxName);
    _profileBox = await Hive.openBox<UserProfile>(_profileBoxName);
    _workoutBox = await Hive.openBox<WorkoutLog>(_workoutBoxName);
    
    debugPrint("Hive DB initialized.");
  }

  Future<List<Exercise>> getAllExercises() async {
    return _exerciseBox.values.where((ex) => !ex.isDeleted).toList();
  }

  Future<void> saveExercise(Exercise ex) async {
    if (ex.id == null) {
      throw Exception("Cannot save Exercise without an ID.");
    }
    await _exerciseBox.put(ex.id!, ex);
    debugPrint("Hive DB saved/updated exercise: ${ex.name}, Status: ${ex.syncStatus}");
  }

  Future<List<Exercise>> getPendingExercises() async {
    return _exerciseBox.values.where((ex) => ex.syncStatus == 'pending').toList();
  }

  Future<List<Template>> getAllTemplates() async {
    return _templateBox.values.where((tpl) => !tpl.isDeleted).toList();
  }

  Future<void> saveTemplate(Template tpl) async {
    if (tpl.id == null) {
      throw Exception("Cannot save Template without an ID.");
    }
    await _templateBox.put(tpl.id!, tpl);
    debugPrint("Hive DB saved/updated template: ${tpl.name}, Status: ${tpl.syncStatus}");
  }

  Future<List<Template>> getPendingTemplates() async {
    return _templateBox.values.where((tpl) => tpl.syncStatus == 'pending').toList();
  }
  
  Future<void> deleteTemplate(String id) async {
    await _templateBox.delete(id);
  }

  Future<UserProfile?> getProfile(String uid) async {
    return _profileBox.get(uid);
  }

  Future<void> saveProfile(UserProfile profile) async {
    if (profile.uid.isEmpty) throw Exception("Profile requires UID.");
    await _profileBox.put(profile.uid, profile);
    debugPrint("Hive DB saved/updated profile: ${profile.name}");
  }

  //workout logs
  Future<List<WorkoutLog>> getAllWorkouts() async {
    return _workoutBox.values.where((w) => !w.isDeleted).toList();
  }

  Future<void> saveWorkout(WorkoutLog log) async {
    if (log.id == null) throw Exception("Cannot save WorkoutLog without an ID.");
    await _workoutBox.put(log.id!, log);
    debugPrint("Hive DB saved workout: ${log.title}, Status: ${log.syncStatus}");
  }

  Future<List<WorkoutLog>> getPendingWorkouts() async {
    return _workoutBox.values.where((w) => w.syncStatus == 'pending').toList();
  }

}

final localDbService = LocalDbService();