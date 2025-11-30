// exercise_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // REQUIRED: For generating unique local IDs

import 'exercise.dart';
import '../../local_db.dart'; // Your Hive implementation
import 'exercise_service.dart'; // Your Firebase functions
import '../../content.dart';          // Your baseExercises list

// --- Configuration ---
const _uuid = Uuid();

// ====================================================================
// THE SYNC MANAGER
// ====================================================================

class SyncManager {
  final Ref ref;
  SyncManager(this.ref) {
    // Start listening to Firebase for remote changes
    // This runs in the background continuously to pull down updates
    ref.listen(remoteExercisesStreamProvider, (_, next) {
      next.whenData((remoteList) {
        _handleRemoteUpdates(remoteList);
      });
    });
  }

  // Called to push pending local changes to Firebase
  Future<void> syncNow() async {
    debugPrint("Sync Manager: Starting sync operation...");
    
    // 1. Get all pending (unsynced) exercises from local DB
    final pending = await localDbService.getPendingExercises();
    
    for (final ex in pending) {
      try {
        // 2. Upload to Firebase
        // Note: ExerciseService.uploadExercise handles whether to create new or update existing.
        await ExerciseService.uploadExercise(ex);
        
        // 3. Update local state and DB to 'synced'
        // Create a new synced Exercise object with the updated status
        final syncedEx = ex.copyWith(syncStatus: 'synced');
        ref.read(customExercisesProvider.notifier).updateSynced(syncedEx);
        
        debugPrint("Sync Manager: Successfully uploaded ${ex.name}");

      } catch (e) {
        // 4. Handle error (e.g., failed network connection, permission denied)
        debugPrint('Sync failed for ${ex.name}: $e');
        // If necessary, update the local record's syncStatus to 'error'
      }
    }
    debugPrint("Sync Manager: Sync operation complete.");
  }
  
  // 5. Handles updates downloaded from Firebase
  void _handleRemoteUpdates(List<Exercise> remoteList) {
    debugPrint("Sync Manager: Handling remote updates...");
    final localList = ref.read(customExercisesProvider).value ?? [];
    
    for (final remoteEx in remoteList) {
      Exercise? localEx; // Declare as nullable type (Exercise?)
      try {
          localEx = localList.firstWhere((e) => e.id == remoteEx.id);
      } catch (e) {
          // localEx remains null if not found
      }
      
      // Simple conflict resolution: If local copy doesn't exist OR remote copy is newer (based on timestamp)
      if (localEx == null || remoteEx.updatedAt > (localEx.updatedAt)) {
        // Update state and local DB with the remote version
        ref.read(customExercisesProvider.notifier).updateSynced(remoteEx.copyWith(syncStatus: 'synced'));
      }
      // If the local copy is newer, the syncNow() loop will handle uploading it.
    }
  }
}

// Provider for the Sync Manager (a simple class, not state)
final syncManagerProvider = Provider((ref) => SyncManager(ref));

// Stream Provider for Firebase Downloads (used only by Sync Manager)
final remoteExercisesStreamProvider = StreamProvider<List<Exercise>>((ref) {
  // This calls the Firebase service method we renamed
  return ExerciseService.downloadUserExercisesStream();
});


// ====================================================================
// THE STATE NOTIFIER (Manages the Custom Exercises List)
// ====================================================================

class CustomExercisesNotifier extends AsyncNotifier<List<Exercise>> {
  
  @override
  Future<List<Exercise>> build() async {
    // 1. Initial load from local DB (Hive)
    return localDbService.getAllExercises();
  }

  // 2. The core ADD function: Local Write First, then Queue Sync
  Future<void> add(Exercise ex) async {
    // Generate a unique local ID (UUID is good for this)
    final newLocalId = _uuid.v4(); 
    
    // Create a local, pending version of the exercise
    final newLocalEx = ex.copyWith(
      id: newLocalId,
      isCustom: true,
      syncStatus: 'pending', // Mark for upload
      updatedAt: DateTime.now().millisecondsSinceEpoch, // Set local timestamp
    );
    
    // 3. Write to local DB (Hive) immediately
    await localDbService.saveExercise(newLocalEx);

    // 4. Update the Riverpod state (UI refreshes immediately)
    state = AsyncData([...(state.value ?? []), newLocalEx]);

    // 5. Trigger the background Sync Manager
    ref.read(syncManagerProvider).syncNow(); 
  }
  
  // 6. Method to update state after a successful sync or remote change
  void updateSynced(Exercise syncedEx) {
    if (state.value == null) return;
    
    // Find the exercise by ID and replace it with the updated version
    final newList = state.value!.map((e) {
      return e.id == syncedEx.id ? syncedEx : e;
    }).toList();
    
    state = AsyncData(newList);
    
    // Also update local DB for persistence
    localDbService.saveExercise(syncedEx);
  }
}

final customExercisesProvider = AsyncNotifierProvider<CustomExercisesNotifier, List<Exercise>>(() => CustomExercisesNotifier());


// ====================================================================
// THE UI CONNECTOR (Merges Base + Custom Data)
// ====================================================================

final allExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final customExercisesAsync = ref.watch(customExercisesProvider);
  
  // Merge static base exercises with user's custom exercises from the local state
  return customExercisesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
    data: (customList) => AsyncValue.data([
      ...baseExercises, // from content.dart
      ...customList,
    ]),
  );
});