import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/screens/home_screen.dart';

void main() {
  testWidgets('add and delete notes', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NoteProvider(),
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(
            onThemeChanged: (_) {},
            onFontScaleChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text(l10n.noNotes), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'title');
    await tester.enterText(find.byType(TextField).at(1), 'content');

    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    expect(find.text('title'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text(l10n.noNotes), findsOneWidget);
  });
}
