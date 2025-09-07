// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Notes & Reminders';

  @override
  String get addNoteReminder => 'Add note / reminder';

  @override
  String get titleLabel => 'Title';

  @override
  String get contentLabel => 'Content';

  @override
  String get fieldRequired => 'This field cannot be empty';

  @override
  String get selectReminderTime => 'Select reminder time';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get noNotes => 'No notes';

  @override
  String get settings => 'Settings';

  @override
  String get chooseThemeColor => 'Choose theme color';

  @override
  String get lowContrastWarning => 'Selected color has low contrast with text';

  @override
  String get changeThemeColor => 'Change theme color';

  @override
  String get chooseMascot => 'Choose mascot';

  @override
  String get changeMascot => 'Change mascot';

  @override
  String get fontSize => 'Font size';

  @override
  String get backupFormat => 'Backup format';

  @override
  String get formatJson => 'JSON';

  @override
  String get formatPdf => 'PDF';

  @override
  String get formatMarkdown => 'Markdown';

  @override
  String get chatAI => 'Chat AI';

  @override
  String get enterMessage => 'Enter message...';

  @override
  String get send => 'Send';

  @override
  String get geminiApiKeyNotConfigured => 'Gemini API key is not configured.';

  @override
  String get noResponse => 'No response.';

  @override
  String geminiError(Object error) {
    return 'Gemini error: $error';
  }

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get networkError => 'Network error. Please try again.';

  @override
  String get noInternetConnection => 'No internet connection.';

  @override
  String get internetConnectionRestored => 'Connection restored.';

  @override
  String get microphonePermissionMessage =>
      'Microphone permission is required. Please enable it in Settings.';

  @override
  String get speechNotRecognizedMessage =>
      'No speech detected. Please try again.';

  @override
  String get readNote => 'Read Note';

  @override
  String scheduleForDate(Object date) {
    return 'Schedule for $date';
  }

  @override
  String get noNotesForDay => 'No notes/reminders for this day';

  @override
  String get addNoteTooltip => 'Add note';

  @override
  String get settingsTooltip => 'Open settings';

  @override
  String get delete => 'Delete';

  @override
  String get timeLabel => 'Time';

  @override
  String get pin => 'Pin';

  @override
  String get share => 'Share';

  @override
  String get markDone => 'Mark done';

  @override
  String get setReminder => 'Set reminder';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get undo => 'Undo';

  @override
  String get notesExported => 'Notes exported';

  @override
  String get notesImported => 'Notes imported';

  @override
  String get repeatLabel => 'Repeat:';

  @override
  String get repeatNone => 'None';

  @override
  String get repeatEveryMinute => 'Every minute';

  @override
  String get repeatHourly => 'Hourly';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String snoozeLabel(Object minutes) {
    return 'Snooze: $minutes min';
  }

  @override
  String get imageLabel => 'Image';

  @override
  String get audioLabel => 'Audio';

  @override
  String get exportNotes => 'Export notes';

  @override
  String get importNotes => 'Import notes';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get allTags => 'All tags';

  @override
  String get addTag => 'Add tag';

  @override
  String get requireAuth => 'Require authentication';

  @override
  String get lockNote => 'Lock note';

  @override
  String get pinNote => 'Pin note';

  @override
  String get colorLabel => 'Color';

  @override
  String get authReason => 'Please authenticate to continue';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get voiceToNote => 'Voice To Note';

  @override
  String get stop => 'Stop';

  @override
  String get speak => 'Speak';

  @override
  String get convertToNote => 'Convert to note';

  @override
  String convertSpeechPrompt(Object recognized) {
    return 'Convert the following speech into a note: $recognized';
  }

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get recurring => 'Recurring';

  @override
  String get daily => 'Daily';

  @override
  String get snooze => 'Snooze';

  @override
  String get done => 'Done';

  @override
  String get scheduledDesc => 'Scheduled notifications';

  @override
  String get recurringDesc => 'Recurring notifications';

  @override
  String get dailyDesc => 'Daily notifications';

  @override
  String get snoozeDesc => 'Snoozed notifications';

  @override
  String get aiSuggestionsTitle => 'AI Suggestions';

  @override
  String get summaryLabel => 'Summary';

  @override
  String get actionItemsLabel => 'Action items';

  @override
  String get datesLabel => 'Dates';

  @override
  String get authFailedMessage =>
      'Anonymous sign-in failed. Limited functionality.';

  @override
  String get notificationFailedMessage => 'Notification setup failed.';

  @override
  String get saveNoteFailed => 'Failed to save note';

  @override
  String get hintReady => 'Ready';

  @override
  String get hintArmed => 'Armed';

  @override
  String get hintActive => 'Active';

  @override
  String get teachAi => 'Teach AI';

  @override
  String get teachAiHint => 'Share feedback or corrections';

  @override
  String get submit => 'Submit';

  @override
  String get feedback => 'Feedback';

  @override
  String get savePreset => 'Save preset';

  @override
  String get insert => 'Insert';

  @override
  String get replace => 'Replace';

  @override
  String get copy => 'Copy';

  @override
  String get preview => 'Preview';

  @override
  String get backupNow => 'Backup now';

  @override
  String get syncStatusIdle => 'Synced';

  @override
  String get syncStatusSyncing => 'Syncing...';

  @override
  String get syncStatusError => 'Sync error';

  @override
  String get showNotes => 'Show Notes';

  @override
  String get showVoiceToNote => 'Show Voice to Note';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get primary => 'Primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get themeUpdated => 'Theme updated';

  @override
  String get notes => 'Notes';

  @override
  String get reminders => 'Reminders';

  @override
  String get palette => 'Palette';

  @override
  String get searchCommandHint => 'Type a command...';

  @override
  String get onboardingTakeNotes => 'Take Notes';

  @override
  String get onboardingTakeNotesDesc => 'Write down your thoughts and ideas.';

  @override
  String get onboardingSetReminders => 'Set Reminders';

  @override
  String get onboardingSetRemindersDesc =>
      'Schedule alarms for important tasks.';

  @override
  String get onboardingCustomize => 'Customize';

  @override
  String get onboardingCustomizeDesc =>
      'Adjust themes and font sizes to your liking.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get Started';
}
