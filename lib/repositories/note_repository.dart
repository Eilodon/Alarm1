import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/note.dart';

class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            alarmTime TEXT,
            daily INTEGER,
            active INTEGER
          )
        ''');
      },
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final maps = await db.query('notes');
    return maps.map(Note.fromJson).toList();
  }

  Future<void> addNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}

