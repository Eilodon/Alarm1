import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../services/tts_service.dart';
import 'chat_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note.title)),
      body: _buildView(),
    );
  }

  Widget _buildView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Tiêu đề'),
          readOnly: true,
        ),
        TextField(
          controller: _contentCtrl,
          decoration: const InputDecoration(labelText: 'Nội dung'),
          readOnly: true,
        ),
        if (widget.note.alarmTime != null)
          Text(
            'Thời gian: '
            '${DateFormat.yMd().add_Hm().format(widget.note.alarmTime!)}',
            style: const TextStyle(fontSize: 16),
          ),
        Text('Kích hoạt: ${widget.note.active ? 'Có' : 'Không'}'),
        if (widget.note.snoozeMinutes > 0)
          Text('Hoãn: ${widget.note.snoozeMinutes} phút'),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => TTSService().speak(_contentCtrl.text),
          child: const Text('Đọc Note'),
        ),
        if (_attachments.isNotEmpty) ...[
          const Divider(),
          ..._attachments.map((a) => ListTile(title: Text(a.split('/').last))),
        ],
        const Divider(),
        Expanded(child: ChatScreen(initialMessage: _contentCtrl.text)),
      ],
    );
  }
}
