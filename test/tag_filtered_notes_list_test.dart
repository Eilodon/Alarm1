import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/providers/note_provider.dart';
import 'package:notes_reminder_app/widgets/tag_filtered_notes_list.dart';
import 'package:alarm_domain/alarm_domain.dart';

void main() {
  testWidgets('filters notes by tag', (tester) async {
    final provider = NoteProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TagFilteredNotesList()),
        ),
      ),
    );

    await provider.addNote(
      const Note(
        id: '1',
        title: 'n1',
        content: 'c1',
        summary: '',
        actionItems: [],
        dates: [],
        tags: ['work'],
      ),
    );
    await provider.addNote(
      const Note(
        id: '2',
        title: 'n2',
        content: 'c2',
        summary: '',
        actionItems: [],
        dates: [],
        tags: ['home'],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('n1'), findsOneWidget);
    expect(find.text('n2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text('work').last);
    await tester.pumpAndSettle();

    expect(find.text('n1'), findsOneWidget);
    expect(find.text('n2'), findsNothing);
  });

  testWidgets('uses theme colors for day indicators in light theme',
      (tester) async {
    final provider = NoteProvider();
    final now = DateTime.now();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(),
          home: const Scaffold(body: TagFilteredNotesList()),
        ),
      ),
    );

    await provider.addNote(
      Note(
        id: '1',
        title: 'n1',
        content: 'c1',
        summary: '',
        actionItems: const [],
        dates: const [],
        alarmTime: now,
      ),
    );
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(TagFilteredNotesList));
    final colorScheme = Theme.of(ctx).colorScheme;
    final containers = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.width == 60 && c.decoration is BoxDecoration)
        .toList();

    final todayBox = containers.first.decoration as BoxDecoration;
    final nextDayBox = containers[1].decoration as BoxDecoration;

    expect(todayBox.color, colorScheme.secondary);
    expect((todayBox.border as Border).top.color, colorScheme.onSurface);
    expect(nextDayBox.color, colorScheme.surface);
  });

  testWidgets('uses theme colors for day indicators in dark theme',
      (tester) async {
    final provider = NoteProvider();
    final now = DateTime.now();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.dark(),
          home: const Scaffold(body: TagFilteredNotesList()),
        ),
      ),
    );

    await provider.addNote(
      Note(
        id: '1',
        title: 'n1',
        content: 'c1',
        summary: '',
        actionItems: const [],
        dates: const [],
        alarmTime: now,
      ),
    );
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(TagFilteredNotesList));
    final colorScheme = Theme.of(ctx).colorScheme;
    final containers = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.width == 60 && c.decoration is BoxDecoration)
        .toList();

    final todayBox = containers.first.decoration as BoxDecoration;
    final nextDayBox = containers[1].decoration as BoxDecoration;

    expect(todayBox.color, colorScheme.secondary);
    expect((todayBox.border as Border).top.color, colorScheme.onSurface);
    expect(nextDayBox.color, colorScheme.surface);
  });
}
