import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/main.dart';

void main() {
  testWidgets('renders home screen title', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(themeColor: Colors.blue));

    expect(find.text('Notes & Reminders'), findsOneWidget);
  });
}
