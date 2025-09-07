import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import '../features/note/domain/domain.dart';

class ReminderControls extends StatelessWidget {
  final DateTime? alarmTime;
  final RepeatInterval? repeat;
  final int snoozeMinutes;
  final ValueChanged<DateTime?> onAlarmTimeChanged;
  final ValueChanged<RepeatInterval?> onRepeatChanged;
  final ValueChanged<int> onSnoozeChanged;

  const ReminderControls({
    super.key,
    required this.alarmTime,
    required this.repeat,
    required this.snoozeMinutes,
    required this.onAlarmTimeChanged,
    required this.onRepeatChanged,
    required this.onSnoozeChanged,
  });

  Future<void> _pickAlarmTime(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: alarmTime ?? now,
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: alarmTime != null
            ? TimeOfDay.fromDateTime(alarmTime!)
            : TimeOfDay.now(),
      );
      if (time != null) {
        onAlarmTimeChanged(
          DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickAlarmTime(context),
              child: Text(l10n.selectReminderTime),
            ),
            if (alarmTime != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  DateFormat.yMd(
                    Localizations.localeOf(context).toString(),
                  ).add_Hm().format(alarmTime!),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(l10n.repeatLabel),
            const SizedBox(width: 8),
            DropdownButton<RepeatInterval?>(
              value: repeat,
              onChanged: onRepeatChanged,
              items: [
                DropdownMenuItem<RepeatInterval?>(
                  value: null,
                  child: Text(l10n.repeatNone),
                ),
                DropdownMenuItem<RepeatInterval?>(
                  value: RepeatInterval.everyMinute,
                  child: Text(l10n.repeatEveryMinute),
                ),
                DropdownMenuItem<RepeatInterval?>(
                  value: RepeatInterval.hourly,
                  child: Text(l10n.repeatHourly),
                ),
                DropdownMenuItem<RepeatInterval?>(
                  value: RepeatInterval.daily,
                  child: Text(l10n.repeatDaily),
                ),
                DropdownMenuItem<RepeatInterval?>(
                  value: RepeatInterval.weekly,
                  child: Text(l10n.repeatWeekly),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l10n.snoozeLabel(snoozeMinutes)),
        Slider(
          value: snoozeMinutes.toDouble(),
          min: 1,
          max: 60,
          divisions: 59,
          label: snoozeMinutes.toString(),
          onChanged: (v) => onSnoozeChanged(v.round()),
        ),
      ],
    );
  }
}
