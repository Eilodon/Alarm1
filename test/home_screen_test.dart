import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/screens/home_screen.dart';

void main() {
  testWidgets('add and delete notes', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NoteProvider(),
        child: MaterialApp(
            home: HomeScreen(
          onThemeChanged: (_) {},
          onFontScaleChanged: (_) {},
        )),
      ),
    );

    expect(find.text('Chưa có ghi chú nào'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'title');
    await tester.enterText(find.byType(TextField).at(1), 'content');

    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('title'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có ghi chú nào'), findsOneWidget);
  });
}
