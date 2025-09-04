import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class DbService {
  static const _kNotes = 'notes_v1';

  Future<List<Note>> getNotes() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kNotes);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Note.fromJson).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(notes.map((e) => e.toJson()).toList());
    await sp.setString(_kNotes, raw);
  }

  Future<void> updateNote(Note note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await saveNotes(notes);
    }
  }
}
