import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'template.dart';

class TemplateService {
  static final _db = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  static const String _boxName = 'templates';
  static StreamSubscription<QuerySnapshot>? _remoteSubscription;
  static StreamSubscription<User?>? _authSubscription;

  static Box<Template> get _box => Hive.box<Template>(_boxName);

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
  static Future<void> saveTemplate(Template tpl) async {
    final String id = tpl.id ?? const Uuid().v4();
    final localTpl = tpl.copyWith(
      id: id,
      uid: _uid, 
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _box.put(id, localTpl);
    _syncToFirebase(localTpl);
  }
  static Future<void> deleteTemplate(String id) async {
    final tpl = _box.get(id);
    if (tpl == null) return;

    final deletedTpl = tpl.copyWith(
      isDeleted: true,
      syncStatus: 'pending',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _box.put(id, deletedTpl);
    _syncToFirebase(deletedTpl);
  }
  static Future<void> _syncToFirebase(Template tpl) async {
    if (_uid.isEmpty) return;

    try {
      if (tpl.isDeleted) {
        // if it was already synced before delete from server
        await _db.collection('users').doc(_uid).collection('templates').doc(tpl.id).delete();
        // to remove from local hive completely after server delete
        await _box.delete(tpl.id);
      } else {
        // Upload/Update
        await _db
            .collection('users')
            .doc(_uid)
            .collection('templates')
            .doc(tpl.id)
            .set(tpl.toMap());
            
        if (_box.containsKey(tpl.id)) {
          final synced = tpl.copyWith(syncStatus: 'synced');
          await _box.put(tpl.id, synced);
        }
      }
    } catch (e) {
      print("Template sync failed: $e");
    }
  }
  static void startListeningToRemoteChanges() {
    if (_uid.isEmpty) return;

    _remoteSubscription?.cancel();
    _remoteSubscription = _db
        .collection('users')
        .doc(_uid)
        .collection('templates')
        .snapshots()
        .listen((snapshot) {
      
      for (final docChange in snapshot.docChanges) {
        final doc = docChange.doc;
        if (docChange.type == DocumentChangeType.removed) {
           _box.delete(doc.id);
           continue;
        }

        final data = doc.data();
        if (data == null) continue;

        var remoteTpl = Template.fromMap(data, id: doc.id);
        if (remoteTpl.uid.isEmpty) {
          remoteTpl = remoteTpl.copyWith(uid: _uid);
        }

        final localTpl = _box.get(remoteTpl.id);

        if (localTpl == null || localTpl.syncStatus != 'pending') {
          final toSave = remoteTpl.copyWith(syncStatus: 'synced');
          _box.put(remoteTpl.id, toSave);
        }
      }
    });
  }

  static Stream<List<Template>> streamTemplates() async* {
    List<Template> getMyTemplates() {
      return _box.values
          .where((t) => t.uid == _uid && !t.isDeleted)
          .toList();
    }

    final initial = getMyTemplates();
    initial.sort((a, b) => a.name.compareTo(b.name));
    yield initial;

    await for (final _ in _box.watch()) {
      final updated = getMyTemplates();
      updated.sort((a, b) => a.name.compareTo(b.name));
      yield updated;
    }
  }
}