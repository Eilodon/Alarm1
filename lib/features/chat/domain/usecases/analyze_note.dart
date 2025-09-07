import '../../data/gemini_service.dart';

class AnalyzeNote {
  final GeminiService _service;
  AnalyzeNote({GeminiService? service}) : _service = service ?? GeminiService();

  Future<NoteAnalysis?> call(String content) {
    return _service.analyzeNote(content);
  }
}
