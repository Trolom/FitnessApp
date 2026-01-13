import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'exercise.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';
import 'exercise_service.dart';
import '../../local_db.dart'; // Ensure path is correct
import '../../content.dart';  // Ensure path is correct for baseExercises

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final _uuid = const Uuid();
  StreamSubscription? _remoteSubscription;

  ExerciseBloc() : super(ExerciseState()) {
    // Register Event Handlers
    on<LoadExercisesEvent>(_onLoadExercises);
    on<AddExerciseEvent>(_onAddExercise);
    on<SyncRemoteUpdatesEvent>(_onSyncRemoteUpdates);
    on<TriggerSyncNowEvent>(_onTriggerSyncNow);

    // Replacement for SyncManager: Listen to Firebase stream immediately
    _remoteSubscription = ExerciseService.downloadUserExercisesStream().listen(
      (remoteList) => add(SyncRemoteUpdatesEvent(remoteList)),
    );
  }

  // 1. Initial Load from Hive
  Future<void> _onLoadExercises(LoadExercisesEvent event, Emitter<ExerciseState> emit) async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final localList = await localDbService.getAllExercises();
      emit(state.copyWith(
        status: ExerciseStatus.success,
        customExercises: localList,
        allExercises: [...baseExercises, ...localList],
      ));
    } catch (e) {
      emit(state.copyWith(status: ExerciseStatus.error, errorMessage: e.toString()));
    }
  }

  // 2. Add Exercise: Local First logic
  Future<void> _onAddExercise(AddExerciseEvent event, Emitter<ExerciseState> emit) async {
    final newLocalEx = event.exercise.copyWith(
      id: _uuid.v4(),
      isCustom: true,
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Update Local DB
    await localDbService.saveExercise(newLocalEx);

    // Update UI State
    final updatedCustom = [...state.customExercises, newLocalEx];
    emit(state.copyWith(
      customExercises: updatedCustom,
      allExercises: [...baseExercises, ...updatedCustom],
    ));

    // Trigger background sync
    add(TriggerSyncNowEvent());
  }

  // 3. Sync Logic: Uploading 'pending' items
  Future<void> _onTriggerSyncNow(TriggerSyncNowEvent event, Emitter<ExerciseState> emit) async {
    final pending = await localDbService.getPendingExercises();
    
    for (final ex in pending) {
      try {
        await ExerciseService.uploadExercise(ex);
        final syncedEx = ex.copyWith(syncStatus: 'synced');
        
        await localDbService.saveExercise(syncedEx);
        _updateSingleExerciseInState(syncedEx, emit);
      } catch (e) {
        print('Sync failed for ${ex.name}: $e');
      }
    }
  }

  // 4. Remote Update Logic: Conflict Resolution
  void _onSyncRemoteUpdates(SyncRemoteUpdatesEvent event, Emitter<ExerciseState> emit) {
    for (final remoteEx in event.remoteExercises) {
      final localExIndex = state.customExercises.indexWhere((e) => e.id == remoteEx.id);
      
      bool shouldUpdate = false;
      if (localExIndex == -1) {
        shouldUpdate = true;
      } else {
        final localEx = state.customExercises[localExIndex];
        if (remoteEx.updatedAt > localEx.updatedAt) {
          shouldUpdate = true;
        }
      }

      if (shouldUpdate) {
        final syncedEx = remoteEx.copyWith(syncStatus: 'synced');
        localDbService.saveExercise(syncedEx);
        _updateSingleExerciseInState(syncedEx, emit);
      }
    }
  }

  // Helper to keep the list updated without reloading everything
  void _updateSingleExerciseInState(Exercise syncedEx, Emitter<ExerciseState> emit) {
    final exists = state.customExercises.any((e) => e.id == syncedEx.id);
    
    List<Exercise> newList;
    if (exists) {
      newList = state.customExercises.map((e) => e.id == syncedEx.id ? syncedEx : e).toList();
    } else {
      newList = [...state.customExercises, syncedEx];
    }

    emit(state.copyWith(
      customExercises: newList,
      allExercises: [...baseExercises, ...newList],
    ));
  }

  @override
  Future<void> close() {
    _remoteSubscription?.cancel(); // Important: Stop listening when BLoC is destroyed
    return super.close();
  }
}