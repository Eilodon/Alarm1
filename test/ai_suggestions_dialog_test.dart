import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/widgets/ai_suggestions_dialog.dart';
import 'package:notes_reminder_app/features/chat/data/gemini_service.dart';

void main() {
  testWidgets('AISuggestionsDialog returns edited data', (tester) async {
    final analysis = NoteAnalysis(
      summary: 'sum',
      actionItems: const ['do'],
      suggestedTags: const ['tag'],
      dates: [DateTime(2024, 1, 1)],
    );
    AISuggestionsResult? result;

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await showDialog<AISuggestionsResult>(
                context: context,
                builder: (_) => AISuggestionsDialog(
                  analysis: analysis,
                  l10n: AppLocalizations.of(context)!,
                ),
              );
            },
            child: const Text('open'),
          );
        },
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byLabelText('Summary'), 'new');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(result?.summary, 'new');
  });
}
