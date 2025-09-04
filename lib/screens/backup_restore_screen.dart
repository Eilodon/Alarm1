import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../services/note_repository.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  Future<void> _exportNotes(BuildContext context) async {
    final repo = NoteRepository();
    final notes = await repo.getNotes();
    final json = jsonEncode(notes.map((e) => e.toJson()).toList());
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/notes_backup.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)], text: 'Notes backup');
  }

  Future<void> _importNotes(BuildContext context) async {
    final repo = NoteRepository();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as List;
      final notes = data.map((e) => Note.fromJson(Map<String, dynamic>.from(e))).toList();
      await repo.importNotes(notes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã khôi phục ghi chú')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _exportNotes(context),
              child: const Text('Export JSON'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _importNotes(context),
              child: const Text('Import JSON'),
            ),
          ],
        ),
      ),
    );
  }
}
