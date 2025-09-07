import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'note_analysis.dart';

abstract class ChatService {
  Future<String> chat(String userText, AppLocalizations l10n);
  Future<NoteAnalysis?> analyzeNote(String content);
}
