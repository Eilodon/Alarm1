import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:pandora/generated/app_localizations.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:alarm_domain/alarm_domain.dart' as domain;
import 'db_service.dart';

class BackupService implements domain.BackupService {
  final DbService _dbService;

  BackupService({DbService? dbService}) : _dbService = dbService ?? DbService();

  @override
  Future<bool> exportNotes(
    List<domain.Note> notes,
    dynamic l10n, {
    String? password,
    domain.BackupFormat format = domain.BackupFormat.json,
  }) async {
    String? path;
    try {
      path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportNotes,
        fileName: 'notes_backup.${format.name}',
        type: FileType.custom,
        allowedExtensions: [format.name],
      );
    } catch (e) {
      debugPrint(l10n.errorWithMessage(e.toString()));
      return false;
    }
    if (path == null) return false;
    final file = File(path);
    switch (format) {
      case domain.BackupFormat.json:
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
      case domain.BackupFormat.pdf:
        final pdf = pw.Document();
        pdf.addPage(
          pw.MultiPage(
            build: (context) => notes
                .map((n) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(n.title, style: pw.TextStyle(fontSize: 18)),
                        pw.SizedBox(height: 8),
                        pw.Text(n.content),
                        pw.SizedBox(height: 20),
                      ],
                    ))
                .toList(),
          ),
        );
        try {
          final data = await pdf.save();
          await file.writeAsBytes(data);
          return true;
        } catch (e) {
          debugPrint(l10n.errorWithMessage(e.toString()));
          return false;
        }
      case domain.BackupFormat.md:
        final buffer = StringBuffer();
        for (final n in notes) {
          buffer.writeln('# ${n.title}\n${n.content}\n');
        }
        try {
          await file.writeAsString(buffer.toString());
          return true;
        } catch (e) {
          debugPrint(l10n.errorWithMessage(e.toString()));
          return false;
        }
    }
  }

  @override
  Future<List<domain.Note>> importNotes(
    dynamic l10n, {
    String? password,
    domain.BackupFormat format = domain.BackupFormat.json,
  }) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: l10n.importNotes,
        type: FileType.custom,
        allowedExtensions: [format.name],
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
    switch (format) {
      case domain.BackupFormat.json:
        try {
          final list = jsonDecode(content) as List<dynamic>;
          final notes = <domain.Note>[];
          for (final m in list) {
            try {
              notes.add(await _dbService.decryptNote(
                m as Map<String, dynamic>,
                password: password,
              ));
            } catch (_) {
              // skip invalid note
            }
          }
          return notes;
        } catch (e) {
          debugPrint(l10n.errorWithMessage(e.toString()));
          return [];
        }
      case domain.BackupFormat.pdf:
        // Importing from PDF is not supported
        return [];
      case domain.BackupFormat.md:
        final notes = <domain.Note>[];
        final lines = content.split('\n');
        String? title;
        final buffer = StringBuffer();
        final uuid = Uuid();
        for (final line in lines) {
          if (line.startsWith('# ')) {
            if (title != null) {
              notes.add(
                domain.Note(
                    id: uuid.v4(),
                    title: title!,
                    content: buffer.toString().trim()),
              );
              buffer.clear();
            }
            title = line.substring(2).trim();
          } else {
            buffer.writeln(line);
          }
        }
        if (title != null) {
          notes.add(
            domain.Note(
                id: uuid.v4(),
                title: title!,
                content: buffer.toString().trim()),
          );
        }
        return notes;
    }
  }

  @override
  Future<bool> autoBackup(List<domain.Note> notes,
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
