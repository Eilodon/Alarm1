import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
 codex/expand-note-model-with-new-fields
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';

import '../services/tts_service.dart';
 codex/add-ask-ai-button-to-notedetailscreen
import '../services/gemini_service.dart';


class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
 codex/expand-note-model-with-new-fields
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late List<String> _tags;
  late List<String> _attachments;
  bool _editing = false;


  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
 codex/expand-note-model-with-new-fields
    _tags = [...widget.note.tags];
    _attachments = [...widget.note.attachments];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _attachments.add(file.path));
    }
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.single.path != null) {
      setState(() => _attachments.add(res.files.single.path!));
    }
  }

  void _save() {
    widget.note
      ..title = _titleCtrl.text
      ..content = _contentCtrl.text
      ..tags = _tags
      ..attachments = _attachments
      ..updatedAt = DateTime.now();
    context.read<NoteProvider>().updateNote(widget.note);
    setState(() => _editing = false);

  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    return Scaffold(
 codex/add-ask-ai-button-to-notedetailscreen
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

