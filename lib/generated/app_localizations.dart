import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes & Reminders'**
  String get appTitle;

  /// No description provided for @addNoteReminder.
  ///
  /// In en, this message translates to:
  /// **'Add note / reminder'**
  String get addNoteReminder;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @contentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentLabel;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty'**
  String get fieldRequired;

  /// No description provided for @selectReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Select reminder time'**
  String get selectReminderTime;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get noNotes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @chooseThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Choose theme color'**
  String get chooseThemeColor;

  /// No description provided for @lowContrastWarning.
  ///
  /// In en, this message translates to:
  /// **'Selected color has low contrast with text'**
  String get lowContrastWarning;

  /// No description provided for @changeThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Change theme color'**
  String get changeThemeColor;

  /// No description provided for @chooseMascot.
  ///
  /// In en, this message translates to:
  /// **'Choose mascot'**
  String get chooseMascot;

  /// No description provided for @changeMascot.
  ///
  /// In en, this message translates to:
  /// **'Change mascot'**
  String get changeMascot;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @backupFormat.
  ///
  /// In en, this message translates to:
  /// **'Backup format'**
  String get backupFormat;

  /// No description provided for @formatJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get formatJson;

  /// No description provided for @formatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get formatPdf;

  /// No description provided for @formatMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get formatMarkdown;

  /// No description provided for @chatAI.
  ///
  /// In en, this message translates to:
  /// **'Chat AI'**
  String get chatAI;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter message...'**
  String get enterMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @geminiApiKeyNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key is not configured.'**
  String get geminiApiKeyNotConfigured;

  /// No description provided for @noResponse.
  ///
  /// In en, this message translates to:
  /// **'No response.'**
  String get noResponse;

  /// No description provided for @geminiError.
  ///
  /// In en, this message translates to:
  /// **'Gemini error: {error}'**
  String geminiError(Object error);

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(Object error);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get networkError;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get noInternetConnection;

  /// No description provided for @internetConnectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored.'**
  String get internetConnectionRestored;

  /// No description provided for @microphonePermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required. Please enable it in Settings.'**
  String get microphonePermissionMessage;

  /// No description provided for @speechNotRecognizedMessage.
  ///
  /// In en, this message translates to:
  /// **'No speech detected. Please try again.'**
  String get speechNotRecognizedMessage;

  /// No description provided for @readNote.
  ///
  /// In en, this message translates to:
  /// **'Read Note'**
  String get readNote;

  /// No description provided for @scheduleForDate.
  ///
  /// In en, this message translates to:
  /// **'Schedule for {date}'**
  String scheduleForDate(Object date);

  /// No description provided for @noNotesForDay.
  ///
  /// In en, this message translates to:
  /// **'No notes/reminders for this day'**
  String get noNotesForDay;

  /// No description provided for @addNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNoteTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get settingsTooltip;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get setReminder;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @notesExported.
  ///
  /// In en, this message translates to:
  /// **'Notes exported'**
  String get notesExported;

  /// No description provided for @notesImported.
  ///
  /// In en, this message translates to:
  /// **'Notes imported'**
  String get notesImported;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat:'**
  String get repeatLabel;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeatNone;

  /// No description provided for @repeatEveryMinute.
  ///
  /// In en, this message translates to:
  /// **'Every minute'**
  String get repeatEveryMinute;

  /// No description provided for @repeatHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get repeatHourly;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @snoozeLabel.
  ///
  /// In en, this message translates to:
  /// **'Snooze: {minutes} min'**
  String snoozeLabel(Object minutes);

  /// No description provided for @imageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageLabel;

  /// No description provided for @audioLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioLabel;

  /// No description provided for @exportNotes.
  ///
  /// In en, this message translates to:
  /// **'Export notes'**
  String get exportNotes;

  /// No description provided for @importNotes.
  ///
  /// In en, this message translates to:
  /// **'Import notes'**
  String get importNotes;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @allTags.
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get allTags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @requireAuth.
  ///
  /// In en, this message translates to:
  /// **'Require authentication'**
  String get requireAuth;

  /// No description provided for @lockNote.
  ///
  /// In en, this message translates to:
  /// **'Lock note'**
  String get lockNote;

  /// No description provided for @pinNote.
  ///
  /// In en, this message translates to:
  /// **'Pin note'**
  String get pinNote;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @authReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to continue'**
  String get authReason;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @voiceToNote.
  ///
  /// In en, this message translates to:
  /// **'Voice To Note'**
  String get voiceToNote;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @convertToNote.
  ///
  /// In en, this message translates to:
  /// **'Convert to note'**
  String get convertToNote;

  /// No description provided for @convertSpeechPrompt.
  ///
  /// In en, this message translates to:
  /// **'Convert the following speech into a note: {recognized}'**
  String convertSpeechPrompt(Object recognized);

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @scheduledDesc.
  ///
  /// In en, this message translates to:
  /// **'Scheduled notifications'**
  String get scheduledDesc;

  /// No description provided for @recurringDesc.
  ///
  /// In en, this message translates to:
  /// **'Recurring notifications'**
  String get recurringDesc;

  /// No description provided for @dailyDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily notifications'**
  String get dailyDesc;

  /// No description provided for @snoozeDesc.
  ///
  /// In en, this message translates to:
  /// **'Snoozed notifications'**
  String get snoozeDesc;

  /// No description provided for @aiSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestions'**
  String get aiSuggestionsTitle;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryLabel;

  /// No description provided for @actionItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Action items'**
  String get actionItemsLabel;

  /// No description provided for @datesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get datesLabel;

  /// No description provided for @authFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Anonymous sign-in failed. Limited functionality.'**
  String get authFailedMessage;

  /// No description provided for @notificationFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification setup failed.'**
  String get notificationFailedMessage;

  /// No description provided for @saveNoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save note'**
  String get saveNoteFailed;

  /// No description provided for @hintReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get hintReady;

  /// No description provided for @hintArmed.
  ///
  /// In en, this message translates to:
  /// **'Armed'**
  String get hintArmed;

  /// No description provided for @hintActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get hintActive;

  /// No description provided for @teachAi.
  ///
  /// In en, this message translates to:
  /// **'Teach AI'**
  String get teachAi;

  /// No description provided for @teachAiHint.
  ///
  /// In en, this message translates to:
  /// **'Share feedback or corrections'**
  String get teachAiHint;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @savePreset.
  ///
  /// In en, this message translates to:
  /// **'Save preset'**
  String get savePreset;

  /// No description provided for @insert.
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get insert;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup now'**
  String get backupNow;

  /// No description provided for @syncStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncStatusIdle;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get syncStatusError;

  /// No description provided for @showNotes.
  ///
  /// In en, this message translates to:
  /// **'Show Notes'**
  String get showNotes;

  /// No description provided for @showVoiceToNote.
  ///
  /// In en, this message translates to:
  /// **'Show Voice to Note'**
  String get showVoiceToNote;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// No description provided for @themeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Theme updated'**
  String get themeUpdated;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @palette.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get palette;

  /// No description provided for @searchCommandHint.
  ///
  /// In en, this message translates to:
  /// **'Type a command...'**
  String get searchCommandHint;

  /// No description provided for @onboardingTakeNotes.
  ///
  /// In en, this message translates to:
  /// **'Take Notes'**
  String get onboardingTakeNotes;

  /// No description provided for @onboardingTakeNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Write down your thoughts and ideas.'**
  String get onboardingTakeNotesDesc;

  /// No description provided for @onboardingSetReminders.
  ///
  /// In en, this message translates to:
  /// **'Set Reminders'**
  String get onboardingSetReminders;

  /// No description provided for @onboardingSetRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Schedule alarms for important tasks.'**
  String get onboardingSetRemindersDesc;

  /// No description provided for @onboardingCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get onboardingCustomize;

  /// No description provided for @onboardingCustomizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust themes and font sizes to your liking.'**
  String get onboardingCustomizeDesc;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
