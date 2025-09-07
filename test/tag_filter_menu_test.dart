import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:notes_reminder_app/widgets/tag_filter_menu.dart';

void main() {
  testWidgets('TagFilterMenu selects tag', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(
            actions: [
              TagFilterMenu(
                tags: const ['work', 'home'],
                selectedTag: null,
                onSelected: (tag) => selected = tag,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text('work').last);
    await tester.pumpAndSettle();

    expect(selected, 'work');
  });
}
