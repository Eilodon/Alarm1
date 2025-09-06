import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes_reminder_app/models/note.dart';
import 'package:notes_reminder_app/services/backup_service.dart';
import 'package:notes_reminder_app/services/db_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const MethodChannel _channel = MethodChannel(
  'miguelruivo.flutter.plugins.filepicker',
);

class _MockFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    final List<Map>? result = await _channel.invokeListMethod<Map>(type.name, {
      'allowMultipleSelection': allowMultiple,
      'allowedExtensions': allowedExtensions,
      'allowCompression': allowCompression,
      'withData': withData,
      'compressionQuality': compressionQuality,
    });
    if (result == null) return null;
    return FilePickerResult(
      result.map((m) => PlatformFile.fromMap(m)).toList(),
    );
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
  }) {
    return _channel.invokeMethod<String>('saveFile', {
      'dialogTitle': dialogTitle,
      'fileName': fileName,
      'type': type.name,
      'allowedExtensions': allowedExtensions,
    });
  }

  @override
  Future<bool?> clearTemporaryFiles() async => null;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupService', () {
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      FilePicker.platform = _MockFilePicker();
      tempDir = await Directory.systemTemp.createTemp();
    });

    tearDown(() async {
      _channel.setMockMethodCallHandler(null);
      await tempDir.delete(recursive: true);
    });

    test('exportNotes writes encrypted file without password', () async {
      final path = '${tempDir.path}/notes.json';
      _channel.setMockMethodCallHandler(
        (call) async => call.method == 'saveFile' ? path : null,
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      const note = Note(id: '1', title: 't', content: 'c');
      final ok = await BackupService().exportNotes([note], l10n);
      expect(ok, true);
      final data = jsonDecode(await File(path).readAsString()) as List<dynamic>;
      final stored = data.first as Map<String, dynamic>;
      expect(stored['content'], isNot('c'));
      expect(stored['iv'], isNotNull);
      expect(stored['tag'], isNotNull);
    });

    test('exportNotes writes encrypted file with password', () async {
      final path = '${tempDir.path}/notes.json';
      _channel.setMockMethodCallHandler(
        (call) async => call.method == 'saveFile' ? path : null,
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      const note = Note(id: '1', title: 't', content: 'c');
      final ok = await BackupService().exportNotes(
        [note],
        l10n,
        password: 'pw',
      );
      expect(ok, true);
      final data = jsonDecode(await File(path).readAsString()) as List<dynamic>;
      final stored = data.first as Map<String, dynamic>;
      expect(stored['content'], isNot('c'));
      expect(stored['iv'], isNotNull);
      expect(stored['tag'], isNotNull);
    });

    test('importNotes reads back data with password', () async {
      final db = DbService();
      const note = Note(id: '1', title: 't', content: 'c');
      final enc = await db.encryptNote(note, password: 'pw');
      final path = '${tempDir.path}/notes.json';
      await File(path).writeAsString(jsonEncode([enc]));
      _channel.setMockMethodCallHandler((call) async {
        if (call.method == 'custom') {
          final file = File(path);
          return [
            {
              'name': 'notes.json',
              'path': path,
              'bytes': null,
              'size': await file.length(),
              'identifier': null,
            },
          ];
        }
        return null;
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final notes = await BackupService(
        dbService: db,
      ).importNotes(l10n, password: 'pw');
      expect(notes.length, 1);
      expect(notes.first.content, 'c');
    });

    test('importNotes returns empty on wrong password', () async {
      final db = DbService();
      const note = Note(id: '1', title: 't', content: 'c');
      final enc = await db.encryptNote(note, password: 'pw');
      final path = '${tempDir.path}/notes.json';
      await File(path).writeAsString(jsonEncode([enc]));
      _channel.setMockMethodCallHandler((call) async {
        if (call.method == 'custom') {
          final file = File(path);
          return [
            {
              'name': 'notes.json',
              'path': path,
              'bytes': null,
              'size': await file.length(),
              'identifier': null,
            },
          ];
        }
        return null;
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final notes = await BackupService(
        dbService: db,
      ).importNotes(l10n, password: 'bad');
      expect(notes, isEmpty);
    });

    test('importNotes returns empty on corrupted file', () async {
      final path = '${tempDir.path}/notes.json';
      await File(path).writeAsString('not json');
      _channel.setMockMethodCallHandler((call) async {
        if (call.method == 'custom') {
          final file = File(path);
          return [
            {
              'name': 'notes.json',
              'path': path,
              'bytes': null,
              'size': await file.length(),
              'identifier': null,
            },
          ];
        }
        return null;
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final notes = await BackupService().importNotes(l10n);
      expect(notes, isEmpty);
    });
  });
}
