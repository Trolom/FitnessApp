import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'misc/exercise/exercise.dart';
import 'misc/template/template.dart';
import 'misc/exercise/exercise_block.dart';
import 'misc/user/user_profile.dart';

const String _exerciseBoxName = 'exercises';
const String _templateBoxName = 'templates';
const String _profileBoxName = 'user_profile';

class LocalDbService {
  
  late Box<Exercise> _exerciseBox;
  late Box<Template> _templateBox;
  late Box<UserProfile> _profileBox;

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
    
    _exerciseBox = await Hive.openBox<Exercise>(_exerciseBoxName);
    _templateBox = await Hive.openBox<Template>(_templateBoxName);
    _profileBox = await Hive.openBox<UserProfile>(_profileBoxName);
    
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

}

final localDbService = LocalDbService();