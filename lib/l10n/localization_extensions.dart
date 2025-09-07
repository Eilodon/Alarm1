import 'package:notes_reminder_app/generated/app_localizations.dart';

extension AppLocalizationsExtras on AppLocalizations {
  String get pinNote => localeName == 'vi' ? 'Ghim ghi chú' : 'Pin note';
  String get colorLabel => localeName == 'vi' ? 'Màu' : 'Color';
}
