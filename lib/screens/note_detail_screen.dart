import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/tts_service.dart';
import '../services/gemini_service.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nội dung: ${note.content}', style: const TextStyle(fontSize: 16)),
            if (note.alarmTime != null)
              Text('Thời gian: ${note.alarmTime}',
                  style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => TTSService().speak(note.content),
              child: const Text('Đọc Note'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                final reply = await GeminiService()
                    .chat('Tóm tắt hoặc gợi ý cho note sau: ${note.content}');
                if (!context.mounted) return;
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Gợi ý từ AI'),
                    content: Text(reply),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      )
                    ],
                  ),
                );
              },
              child: const Text('Ask AI'),
            ),
          ],
        ),
      ),
    );
  }
}
