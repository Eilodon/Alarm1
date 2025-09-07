import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/note.dart';

class DbService {
  static const _kNotes = 'notes_v2';
  static const _kLegacyNotes = 'notes_v1';
  static const _kEncKey = 'enc_key';

  final _secure = const FlutterSecureStorage();

  Future<List<int>> _getKey() async {
    var key = await _secure.read(key: _kEncKey);
    if (key == null) {
      final rand = Random.secure();
      final values = List<int>.generate(32, (_) => rand.nextInt(256));
      key = base64UrlEncode(values);
      await _secure.write(key: _kEncKey, value: key);
    }
    return base64Url.decode(key);
  }

  Future<List<int>> _deriveKeyFromPassword(String password) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: utf8.encode('notes_backup_salt'),
    );
    return secretKey.extractBytes();
  }

  Future<List<Note>> getNotes({
    void Function(String noteId)? onDecryptFailure,
  }) async {
    final sp = await SharedPreferences.getInstance();
    var raw = sp.getString(_kNotes);
    raw ??= sp.getString(_kLegacyNotes);
    if (raw == null) return [];
    final keyBytes = await _getKey();
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(keyBytes);
    final legacyEncrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(keyBytes)),
    );
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final notes = <Note>[];
    final failedIds = <String>[];
    for (final m in list) {
      final id = m['id'] as String?;
      final ivString = m['iv'];
      final tagString = m['tag'];
      final content = m['content'] as String;
      try {
        if (tagString != null) {
          final box = SecretBox(
            base64Decode(content),
            nonce: base64Decode(ivString),
            mac: Mac(base64Decode(tagString)),
          );
          final decrypted = await algorithm.decrypt(box, secretKey: secretKey);
          m['content'] = utf8.decode(decrypted);
        } else {
          final iv = ivString != null
              ? encrypt.IV.fromBase64(ivString)
              : encrypt.IV.fromLength(16);
          final decrypted = legacyEncrypter.decrypt64(content, iv: iv);
          m['content'] = decrypted;
        }
        notes.add(Note.fromJson(m));
      } catch (_) {
        if (id != null) {
          failedIds.add(id);
          onDecryptFailure?.call(id);
          debugPrint('Failed to decrypt note $id');
        }
      }
    }
    if (failedIds.isNotEmpty) {
      debugPrint('Failed to decrypt notes: ${failedIds.join(', ')}');
    }
    return notes;
  }

  Future<void> saveNotes(List<Note> notes) async {
    final sp = await SharedPreferences.getInstance();
    final list = <Map<String, dynamic>>[];
    for (final n in notes) {
      list.add(await encryptNote(n));
    }
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

  Future<Map<String, dynamic>> encryptNote(
    Note note, {
    String? password,
  }) async {
    final keyBytes = password != null
        ? await _deriveKeyFromPassword(password)
        : await _getKey();
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(keyBytes);
    final m = note.toJson();
    final iv = List<int>.generate(12, (_) => Random.secure().nextInt(256));
    final box = await algorithm.encrypt(
      utf8.encode(m['content']),
      secretKey: secretKey,
      nonce: iv,
    );
    m['content'] = base64Encode(box.cipherText);
    m['iv'] = base64Encode(iv);
    m['tag'] = base64Encode(box.mac.bytes);
    return m;
  }

  Future<Note> decryptNote(
    Map<String, dynamic> data, {
    String? password,
  }) async {
    final keyBytes = password != null
        ? await _deriveKeyFromPassword(password)
        : await _getKey();
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(keyBytes);
    final legacyEncrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(keyBytes)),
    );
    final ivString = data['iv'];
    final tagString = data['tag'];
    final content = data['content'] as String;
    if (tagString != null) {
      final box = SecretBox(
        base64Decode(content),
        nonce: base64Decode(ivString),
        mac: Mac(base64Decode(tagString)),
      );
      final decrypted = await algorithm.decrypt(box, secretKey: secretKey);
      data['content'] = utf8.decode(decrypted);
    } else {
      final iv = ivString != null
          ? encrypt.IV.fromBase64(ivString)
          : encrypt.IV.fromLength(16);
      final decrypted = legacyEncrypter.decrypt64(content, iv: iv);
      data['content'] = decrypted;
    }
    return Note.fromJson(data);
  }
}
