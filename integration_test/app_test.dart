import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pandora/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('add and delete note and verify navigation', (tester) async {
    SharedPreferences.setMockInitialValues({});

    app.main();
    await tester.pumpAndSettle();

    expect(find.text('No notes'), findsOneWidget);

    await tester.tap(find.byTooltip('Add note'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'Test Note');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Content'), 'Sample content');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Test Note'), findsOneWidget);

    await tester.tap(find.text('Test Note'));
    await tester.pumpAndSettle();
    expect(find.text('Read Note'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No notes'), findsOneWidget);
  });
}
