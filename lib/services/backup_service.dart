import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/note.dart';

class BackupService {
  Future<void> exportNotes(List<Note> notes, AppLocalizations l10n) async {
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
      return;
    }
    if (path == null) return;
    final file = File(path);
    final data = jsonEncode(notes.map((n) => n.toJson()).toList());
    try {
      await file.writeAsString(data);
    } catch (e) {
      debugPrint(l10n.errorWithMessage(e.toString()));
    }
  }

  Future<List<Note>> importNotes(AppLocalizations l10n) async {
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
    final list = jsonDecode(content) as List<dynamic>;
    return list
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

