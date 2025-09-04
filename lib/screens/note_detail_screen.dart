import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
 codex/expand-note-model-with-new-fields
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';

import '../services/tts_service.dart';
import '../widgets/tag_selector.dart';
import 'chat_screen.dart';
 codex/expand-note-model-with-new-fields


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
 codex/expand-note-model-with-new-fields
      appBar: AppBar(
        title: Text(_editing ? 'Chỉnh sửa' : widget.note.title),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_editing) {
                _save();
              } else {
                setState(() => _editing = true);
              }
            },
          )
        ],
      ),
      body: _editing ? _buildEdit(provider) : _buildView(),
    );
  }

  Widget _buildView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nội dung: ${widget.note.content}',
            style: const TextStyle(fontSize: 16)),
        if (widget.note.alarmTime != null)
          Text('Thời gian: ${widget.note.alarmTime}',
              style: const TextStyle(fontSize: 16)),
        Wrap(
          children: widget.note.tags
              .map((t) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Chip(label: Text(t)),
                  ))
              .toList(),
        ),
        Expanded(
          child: ListView(
            children: [
              ...widget.note.attachments
                  .map((a) => ListTile(title: Text(a))).toList(),
              ElevatedButton(
                onPressed: () => TTSService().speak(widget.note.content),
                child: const Text('Đọc Note'),
              ),
              const Divider(),
              SizedBox(
                height: 200,
                child: ChatScreen(initialMessage: widget.note.content),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEdit(NoteProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Tiêu đề'),
          ),
          TextField(
            controller: _contentCtrl,
            decoration: const InputDecoration(labelText: 'Nội dung'),
            maxLines: null,
          ),
          const SizedBox(height: 8),
          TagSelector(
            availableTags: provider.allTags,
            selectedTags: _tags,
            allowCreate: true,
            onChanged: (t) => setState(() => _tags = t),
          ),
          const SizedBox(height: 8),
          Wrap(
            children: _attachments
                .map((a) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Chip(
                        label: Text(a.split('/').last),
                        onDeleted: () =>
                            setState(() => _attachments.remove(a)),
                      ),
                    ))
                .toList(),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Chọn ảnh'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _pickAudio,
                child: const Text('Chọn audio'),
              ),
            ],
          ),

        ],
        const Divider(),
        Expanded(child: ChatScreen(initialMessage: _contentCtrl.text)),
      ],
    );
  }
}

