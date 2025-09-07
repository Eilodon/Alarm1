import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'note_analysis.dart';

abstract class ChatService {
  Future<String> chat(String userText, AppLocalizations l10n);
  Future<NoteAnalysis?> analyzeNote(String content);
}
