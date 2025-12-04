import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; 
import '../../content.dart';
import 'workout_log.dart';

class WorkoutService {
  static final _db = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  
  static const String _boxName = 'workouts'; 
  static Box<WorkoutLog> get _box => Hive.box<WorkoutLog>(_boxName);
  static Future<void> saveWorkout(WorkoutLog log) async {
    final String id = log.id ?? const Uuid().v4();
    
    final localLog = log.copyWith(
      id: id,
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _box.put(id, localLog);
    _syncToFirebase(localLog);
  }
  static Future<void> _syncToFirebase(WorkoutLog log) async {
    if (_uid.isEmpty) return;

    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('workouts')
          .doc(log.id)
          .set(log.toMap());
      if (_box.containsKey(log.id)) {
        final syncedLog = log.copyWith(syncStatus: 'synced');
        await _box.put(log.id, syncedLog);
      }
      
    } catch (e) {
      print("Offline: Data saved locally. Sync failed: $e");
    }
  }
  static Future<void> syncPendingWorkouts() async {
    if (_uid.isEmpty) return;
    
    final pendingLogs = _box.values.where((l) => l.syncStatus == 'pending');
    for (final log in pendingLogs) {
      await _syncToFirebase(log);
    }
  }
  static Stream<List<WorkoutLog>> streamWorkouts() async* {
    final initial = _box.values.toList();
    initial.sort((a, b) => b.when.compareTo(a.when));
    yield initial;

    await for (final _ in _box.watch()) {
      final updated = _box.values.toList();
      updated.sort((a, b) => b.when.compareTo(a.when));
      yield updated;
    }
  }

  static Stream<Map<DateTime, Map<String, int>>> muscleWorkByDayStream() {
    return streamWorkouts().map((workouts) {
      final result = <DateTime, Map<String, int>>{};

      for (final w in workouts) {
        if (w.isDeleted) continue; 

        final dayKey = DateTime(w.when.year, w.when.month, w.when.day);
        result.putIfAbsent(dayKey, () => {});

        for (final rawMuscle in w.muscles) {
          final group = muscleToGroup[rawMuscle];
          if (group == null) continue;
          result[dayKey]![group] = (result[dayKey]![group] ?? 0) + 1;
        }
      }
      return result;
    });
  }

  static Stream<Map<String, int>> totalMuscleVolumeStream() {
    return muscleWorkByDayStream().map((dayMap) {
      final totals = <String, int>{};
      for (final dayEntry in dayMap.values) {
        for (final muscleEntry in dayEntry.entries) {
          totals[muscleEntry.key] =
              (totals[muscleEntry.key] ?? 0) + muscleEntry.value;
        }
      }
      return totals;
    });
  }
}