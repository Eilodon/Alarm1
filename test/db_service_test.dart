import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notes_reminder_app/services/db_service.dart';
import 'package:alarm_domain/alarm_domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('getNotes reports corrupted entries', () async {
    final db = DbService();
    final notes = const [
      Note(id: 'good', title: 't', content: 'c'),
      Note(id: 'bad', title: 't2', content: 'c2'),
    ];
    await db.saveNotes(notes);

    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('notes_v2');
    final list = (jsonDecode(raw!) as List).cast<Map<String, dynamic>>();
    final badMap = list.firstWhere((m) => m['id'] == 'bad');
    final tagBytes = base64Decode(badMap['tag']);
    tagBytes[0] ^= 0xFF;
    badMap['tag'] = base64Encode(tagBytes);
    await sp.setString('notes_v2', jsonEncode(list));

    final failed = <String>[];
    final result = await db.getNotes(onDecryptFailure: failed.add);

    expect(result.length, 1);
    expect(result.first.id, 'good');
    expect(failed, ['bad']);
  });
}
