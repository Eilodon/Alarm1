import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:notes_reminder_app/widgets/attachment_section.dart';

void main() {
  testWidgets('AttachmentSection deletes attachment', (tester) async {
    List<String>? changed;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AttachmentSection(
        attachments: const ['a.txt'],
        onChanged: (v) => changed = v,
      ),
    ));

    expect(find.text('a.txt'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(changed, isEmpty);
  });
}
