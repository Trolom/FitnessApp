import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'template.dart';

class TemplateService {
  static final _firestore = FirebaseFirestore.instance;

  static String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not logged in');
    }
    return uid;
  }

  static Future<void> addUserTemplate(Template tpl) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('templates')
        .add(tpl.toMap());
  }

  // stream user templates and include each document id.
  static Stream<List<Template>> userTemplates() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('templates')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Template.fromDoc(d)) // includes d.id
            .toList());
  }

  // delete by document id
  static Future<void> deleteUserTemplate(String id) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('templates')
        .doc(id)
        .delete();
  }
}