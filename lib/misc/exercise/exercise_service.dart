import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'exercise.dart';

class ExerciseService {
  static final _firestore = FirebaseFirestore.instance;

  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  // 1. New method to handle UPLOADING a single local exercise to Firebase
  static Future<void> uploadExercise(Exercise ex) async {
    final collection = _firestore.collection('users').doc(uid).collection('exercises');
    
    // Use SET if ID exists (update), or ADD if ID is null (new)
    if (ex.id != null && ex.isCustom) {
      // SET will overwrite or create the document with the specific ID
      await collection.doc(ex.id).set(ex.toMap()); 
    } else {
      // ADD lets Firebase generate the ID for a brand new document
      await collection.add(ex.toMap());
    }
  }

  // 2. The Stream is used only by the Sync Manager for DOWLOADING remote changes
  static Stream<List<Exercise>> downloadUserExercisesStream() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .snapshots()
        .map((snap) =>
            // Capture the doc.id and pass it to fromMap
            snap.docs.map((doc) => Exercise.fromMap(doc.data(), id: doc.id)).toList());
  }
}