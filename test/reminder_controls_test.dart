import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:notes_reminder_app/widgets/reminder_controls.dart';

void main() {
  testWidgets('ReminderControls updates repeat and snooze', (tester) async {
    RepeatInterval? repeat;
    int? snooze;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReminderControls(
        alarmTime: null,
        repeat: null,
        snoozeMinutes: 5,
        onAlarmTimeChanged: (_) {},
        onRepeatChanged: (v) => repeat = v,
        onSnoozeChanged: (v) => snooze = v,
      ),
    ));

    await tester.tap(find.byType(DropdownButton<RepeatInterval?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily').last);
    await tester.pumpAndSettle();
    expect(repeat, RepeatInterval.daily);

    await tester.drag(find.byType(Slider), const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(snooze, isNotNull);
    expect(snooze, isNot(5));
  });
}
