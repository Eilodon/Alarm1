import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/note.dart';

class BackupService {
  Future<void> exportNotes(List<Note> notes) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Notes',
      fileName: 'notes_backup.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (path == null) return;
    final file = File(path);
    final data = jsonEncode(notes.map((n) => n.toJson()).toList());
    await file.writeAsString(data);
  }

  Future<List<Note>> importNotes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return [];
    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final list = jsonDecode(content) as List<dynamic>;
    return list
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

