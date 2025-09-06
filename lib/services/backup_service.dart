import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

import '../models/note.dart';
import 'db_service.dart';

class BackupService {
  final DbService _dbService;

  BackupService({DbService? dbService})
      : _dbService = dbService ?? DbService();

  Future<bool> exportNotes(List<Note> notes, AppLocalizations l10n,
      {String? password}) async {
    String? path;
    try {
      path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportNotes,
        fileName: 'notes_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
    } catch (e) {
      debugPrint(l10n.errorWithMessage(e.toString()));
      return false;
    }
    if (path == null) return false;
    final file = File(path);
    final list = <Map<String, dynamic>>[];
    for (final n in notes) {
      list.add(await _dbService.encryptNote(n, password: password));
    }
    final data = jsonEncode(list);
    try {
      await file.writeAsString(data);
      return true;
    } catch (e) {
      debugPrint(l10n.errorWithMessage(e.toString()));
      return false;
    }
  }

  Future<List<Note>> importNotes(AppLocalizations l10n,
      {String? password}) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: l10n.importNotes,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
    } catch (e) {
      debugPrint(l10n.errorWithMessage(e.toString()));
      return [];
    }
    if (result == null || result.files.single.path == null) return [];
    final file = File(result.files.single.path!);
    String content;
    try {
      content = await file.readAsString();
    } catch (e) {
      debugPrint(l10n.errorWithMessage(e.toString()));
      return [];
    }
    try {
      final list = jsonDecode(content) as List<dynamic>;
      final notes = <Note>[];
      for (final m in list) {
        try {
          notes.add(await _dbService.decryptNote(
              m as Map<String, dynamic>,
              password: password));
        } catch (_) {
          // skip invalid note
        }
      }
      return notes;
    } catch (e) {
      debugPrint(l10n.errorWithMessage(e.toString()));
      return [];
    }
  }

  Future<bool> autoBackup(List<Note> notes,
      {String fileName = 'notes_autobackup.json'}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      final list = <Map<String, dynamic>>[];
      for (final n in notes) {
        list.add(await _dbService.encryptNote(n));
      }
      await file.writeAsString(jsonEncode(list));
      return true;
    } catch (e) {
      debugPrint('autoBackup error: $e');
      return false;
    }
  }
}

