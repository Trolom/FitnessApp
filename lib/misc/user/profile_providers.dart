import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile.dart';
import 'profile_service.dart';

// use the same auth provider logic or define it here if not shared
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  ref.watch(authStateProvider);
  
  return ProfileService.streamProfile();
});

class ProfileController {
  final Ref ref;
  ProfileController(this.ref);

  Future<void> updateProfile(UserProfile profile) async {
    await ProfileService.saveProfile(profile);
  }
}

final profileControllerProvider = Provider((ref) => ProfileController(ref));