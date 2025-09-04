import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note.dart';

class NoteRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _uid() async {
    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
    return user!.uid;
  }

  Future<List<Note>> fetchNotes() async {
    final uid = await _uid();
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .get();
    return snapshot.docs
        .map((d) => Note.fromJson({"id": d.id, ...d.data()}))
        .toList();
  }

  Future<void> setNote(Note note) async {
    final uid = await _uid();
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson());
  }

  Future<void> delete(String id) async {
    final uid = await _uid();
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(id)
        .delete();
  }

  Future<void> overwriteAll(List<Note> notes) async {
    final uid = await _uid();
    final col = _firestore.collection('users').doc(uid).collection('notes');
    final batch = _firestore.batch();
    final existing = await col.get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    for (final note in notes) {
      batch.set(col.doc(note.id), note.toJson());
    }
    await batch.commit();
  }
}
