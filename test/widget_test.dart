import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes_reminder_app/app.dart';
import 'package:notes_reminder_app/features/note/presentation/providers/note_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders home screen title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider(
          create: (_) => NoteProvider(),
          child: MyApp(
            themeColor: Colors.blue,
            fontScale: 1.0,
            themeMode: ThemeMode.system,
            hasSeenOnboarding: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ghi chú & Nhắc nhở'), findsOneWidget);
  });
}
