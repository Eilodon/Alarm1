import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class DbService {
  static const _kNotes = 'notes_v2';
  static const _kLegacyNotes = 'notes_v1';
  static const _kEncKey = 'enc_key';

  final _secure = const FlutterSecureStorage();

  Future<encrypt.Key> _getKey() async {
    var key = await _secure.read(key: _kEncKey);
    if (key == null) {
      final rand = Random.secure();
      final values = List<int>.generate(32, (_) => rand.nextInt(256));
      key = base64UrlEncode(values);
      await _secure.write(key: _kEncKey, value: key);
    }
    return encrypt.Key.fromBase64(key);
  }

  Future<List<Note>> getNotes() async {
    final sp = await SharedPreferences.getInstance();
    var raw = sp.getString(_kNotes);
    raw ??= sp.getString(_kLegacyNotes);
    if (raw == null) return [];
    final key = await _getKey();
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((m) {
      final decrypted = encrypter.decrypt64(m['content'], iv: iv);
      m['content'] = decrypted;
      return Note.fromJson(m);
    }).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final sp = await SharedPreferences.getInstance();
    final key = await _getKey();
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final list = notes.map((n) {
      final m = n.toJson();
      m['content'] = encrypter.encrypt(m['content'], iv: iv).base64;
      return m;
    }).toList();
    final raw = jsonEncode(list);
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
