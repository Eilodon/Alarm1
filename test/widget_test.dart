import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/main.dart';

void main() {
 codex/enable-material-3-and-customize-theme
  testWidgets('App builds and shows Notes tab', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(themeColor: Colors.blue));
    expect(find.text('Notes'), findsOneWidget);

  });
}
