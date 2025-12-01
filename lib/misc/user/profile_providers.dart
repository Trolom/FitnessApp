import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile.dart';
import '../../local_db.dart';
import 'profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSyncManager {
  final Ref ref;
  ProfileSyncManager(this.ref) {
    ref.listen(remoteProfileStreamProvider, (_, next) {
      next.whenData((remoteProfile) {
        _handleRemoteUpdates(remoteProfile);
      });
    });
  }

  Future<void> syncNow() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final localProfile = await localDbService.getProfile(uid);
    if (localProfile == null || localProfile.syncStatus != 'pending') return;
    
    try {
      await ProfileService.uploadProfile(localProfile);
      
      // Mark local copy as synced
      final syncedProfile = localProfile.copyWith(syncStatus: 'synced');
      ref.read(userProfileProvider.notifier).updateState(syncedProfile);

      debugPrint("Profile Sync Manager: Uploaded profile data.");
    } catch (e) {
      debugPrint('Profile Sync failed: $e');
    }
  }

  void _handleRemoteUpdates(UserProfile remoteProfile) {
    final localProfile = ref.read(userProfileProvider).value;
    
    // Remote update wins if local doesn't exist or is older/not pending upload
    if (localProfile == null || 
        (remoteProfile.updatedAt > localProfile.updatedAt && localProfile.syncStatus != 'pending')) {
      ref.read(userProfileProvider.notifier).updateState(remoteProfile.copyWith(syncStatus: 'synced'));
    }
  }
}

final profileSyncManagerProvider = Provider((ref) => ProfileSyncManager(ref));

final remoteProfileStreamProvider = StreamProvider<UserProfile>((ref) {
  return ProfileService.downloadProfileStream();
});


class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Future<UserProfile> build() async {
    // Try to load from Hive first
    final cached = await localDbService.getProfile(uid);
    if (cached != null) {
      // If we have cached data, trigger a background sync immediately
      ref.read(profileSyncManagerProvider).syncNow(); 
      return cached;
    }

    // If no cache, we wait for the first remote download (and sync)
    final remote = await ref.watch(remoteProfileStreamProvider.future);
    return remote;
  }
  
  Future<void> updateProfile(UserProfile newProfile) async {
    final updatedProfile = newProfile.copyWith(
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await localDbService.saveProfile(updatedProfile);

    state = AsyncData(updatedProfile);

    ref.read(profileSyncManagerProvider).syncNow();
  }
  
  // Method used by the Sync Manager to update state
  void updateState(UserProfile profile) {
    state = AsyncData(profile);
    localDbService.saveProfile(profile);
  }
}

final userProfileProvider = AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
  () => UserProfileNotifier(),
);