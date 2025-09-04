import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/models/note.dart';
import 'package:notes_reminder_app/screens/note_detail_screen.dart';

void main() {
  testWidgets('display note and trigger TTS', (tester) async {
    final note = Note(id: '1', title: 'title', content: 'content');

    const channel = MethodChannel('flutter_tts');
    final calls = <MethodCall>[];
    channel.setMockMethodCallHandler((call) async {
      calls.add(call);
      return null;
    });

    await tester.pumpWidget(const MaterialApp(home: NoteDetailScreen(note: note)));

    // The note content should be displayed inside a read-only text field.
    expect(find.text('content'), findsOneWidget);

    await tester.tap(find.text('Đọc Note'));
    await tester.pump();

    expect(calls.any((c) => c.method == 'speak'), isTrue);

    channel.setMockMethodCallHandler(null);
  });
}
