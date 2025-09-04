import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/note.dart';
import '../services/tts_service.dart';
import 'chat_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${AppLocalizations.of(context)!.contentLabel}: ${note.content}',
              style: const TextStyle(fontSize: 16)),
          if (note.alarmTime != null)
            Text('${AppLocalizations.of(context)!.timeLabel}: ${note.alarmTime}',
                style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => TTSService().speak(note.content),
            child: Text(AppLocalizations.of(context)!.readNote),
          ),
          const Divider(),
          Expanded(child: ChatScreen(initialMessage: note.content)),
        ],
      ),
    );
  }
}
