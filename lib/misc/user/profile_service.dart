import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile.dart';

class ProfileService {
  static final _firestore = FirebaseFirestore.instance;

  static String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not logged in');
    }
    return uid;
  }

  static Future<void> uploadProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  static Stream<UserProfile> downloadProfileStream() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .map((snap) {
          if (!snap.exists || snap.data() == null) {
            return UserProfile(uid: _uid, name: 'New User', syncStatus: 'pending');
          }
          return UserProfile.fromMap(_uid, snap.data()!);
        });
  }
}