import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_profile.dart';

class ProfileService {
  static final _firestore = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  
  static const String _boxName = 'user_profile';

  static StreamSubscription<DocumentSnapshot>? _remoteSubscription;
  static StreamSubscription<User?>? _authSubscription;

  static Box<UserProfile> get _box => Hive.box<UserProfile>(_boxName);

  static void monitorAuthState() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        startListeningToRemoteChanges();
      } else {
        _remoteSubscription?.cancel();
      }
    });
  }

  static Future<void> saveProfile(UserProfile profile) async {
    if (_uid.isEmpty) return;

    final localProfile = profile.copyWith(
      uid: _uid,
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _box.put(_uid, localProfile);
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .set(localProfile.toMap(), SetOptions(merge: true));
      
      final synced = localProfile.copyWith(syncStatus: 'synced');
      await _box.put(_uid, synced);
      
    } catch (e) {
      print("Profile saved offline. Sync failed: $e");
    }
  }

  static void startListeningToRemoteChanges() {
    if (_uid.isEmpty) return;

    _remoteSubscription?.cancel();
    _remoteSubscription = _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .listen((snapshot) {
      
      if (!snapshot.exists || snapshot.data() == null) return;

      final remoteData = snapshot.data()!;
      final remoteProfile = UserProfile.fromMap(_uid, remoteData);
      
      final localProfile = _box.get(_uid);

      // Only overwrite if local is NOT pending (user editing)
      if (localProfile == null || localProfile.syncStatus != 'pending') {
        final toSave = remoteProfile.copyWith(syncStatus: 'synced');
        _box.put(_uid, toSave);
      }
    });
  }

  static Stream<UserProfile?> streamProfile() async* {
    yield _box.get(_uid);

    await for (final _ in _box.watch()) {
      yield _box.get(_uid);
    }
  }
}