import 'package:flutter_test/flutter_test.dart';

import 'package:notes_reminder_app/models/note.dart';

void main() {
  test('Note serialization round trip', () {
    final note = Note(id: '1', title: 't', content: 'c');
    final json = note.toJson();
    final restored = Note.fromJson(json);
    expect(restored.title, 't');
    expect(restored.content, 'c');
  });
}
