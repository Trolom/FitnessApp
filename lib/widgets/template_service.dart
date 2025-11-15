import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/template.dart';

class TemplateService {
  static final _firestore = FirebaseFirestore.instance;
  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<void> addUserTemplate(Template tpl) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('templates')
        .add(tpl.toMap());
  }

  static Stream<List<Template>> userTemplates() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('templates')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Template.fromMap(d.data())).toList());
  }
}
