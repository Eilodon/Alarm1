import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsExtras on AppLocalizations {
  String get pinNote => localeName == 'vi' ? 'Ghim ghi chú' : 'Pin note';
  String get colorLabel => localeName == 'vi' ? 'Màu' : 'Color';
}
