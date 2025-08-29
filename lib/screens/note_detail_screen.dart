import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/db_service.dart';
import '../services/gemini_service.dart';
import '../services/tts_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _db = DbService();
  final _gemini = GeminiService();
  final _tts = TtsService();

  final _chatCtrl = TextEditingController();
  final List<Map<String, String>> _chat = [];
  bool _loading = false;

  Future<void> _send() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chat.add({'role': 'user', 'text': text});
      _loading = true;
      _chatCtrl.clear();
    });
    final reply = await _gemini.chat(text);
    setState(() {
      _chat.add({'role': 'ai', 'text': reply});
      _loading = false;
    });
  }

  Future<void> _read(String text) async {
    final err = await _tts.synth(text);
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.note;
    return Scaffold(
      appBar: AppBar(
        title: Text(n.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _read(n.content.isEmpty ? n.title : n.content),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Nội dung'),
            subtitle: Text(n.content.isEmpty ? '(trống)' : n.content),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _chat.length,
              itemBuilder: (ctx, i) {
                final m = _chat[i];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Hỏi Gemini...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _send,
                  child: const Text('Gửi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
