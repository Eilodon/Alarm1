import '../models/note.dart';
import 'db_service.dart';
import 'note_remote_data_source.dart';

class NoteRepository {
  NoteRepository._internal();
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;

  final DbService _local = DbService();
  final NoteRemoteDataSource _remote = NoteRemoteDataSource();

  Future<List<Note>> getNotes() async {
    final localNotes = await _local.getNotes();
    try {
      final remoteNotes = await _remote.fetchNotes();
      await _local.saveNotes(remoteNotes);
      return remoteNotes;
    } catch (_) {
      return localNotes;
    }
  }

  Future<void> addOrUpdate(Note note) async {
    final notes = await _local.getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    await _local.saveNotes(notes);
    try {
      await _remote.setNote(note);
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    final notes = await _local.getNotes();
    notes.removeWhere((n) => n.id == id);
    await _local.saveNotes(notes);
    try {
      await _remote.delete(id);
    } catch (_) {}
  }

  Future<void> importNotes(List<Note> notes) async {
    await _local.saveNotes(notes);
    try {
      await _remote.overwriteAll(notes);
    } catch (_) {}
  }
}
