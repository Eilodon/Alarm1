import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/main.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';

void main() {
 codex/convert-notedetailscreen-to-statefulwidget
  testWidgets('renders home screen title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(themeColor: Colors.blue, noteProvider: NoteProvider()),
    );


  });
}
