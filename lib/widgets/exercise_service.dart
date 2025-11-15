import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'exercise.dart';

class ExerciseService {
  static final _firestore = FirebaseFirestore.instance;

  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<void> addCustomExercise(Exercise ex) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .add(ex.toMap());
  }

  static Stream<List<Exercise>> userExercisesStream() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Exercise.fromMap(doc.data())).toList());
  }
}
