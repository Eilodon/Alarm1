import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/main.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders home screen title', (WidgetTester tester) async {
    runApp(
      ChangeNotifierProvider(
        create: (_) => NoteProvider(),
        child: MyApp(themeColor: Colors.blue, fontScale: 1.0),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ghi chú & Nhắc nhở'), findsOneWidget);
  });
}
