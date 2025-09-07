import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../data/gemini_service.dart';

class ChatWithGemini {
  final GeminiService _service;
  ChatWithGemini({GeminiService? service}) : _service = service ?? GeminiService();

  Future<String> call(String userText, AppLocalizations l10n) {
    return _service.chat(userText, l10n);
  }
}
