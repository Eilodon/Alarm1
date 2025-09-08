import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class AttachmentSection extends StatelessWidget {
  final List<String> attachments;
  final ValueChanged<List<String>> onChanged;

  const AttachmentSection(
      {super.key, required this.attachments, required this.onChanged});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final newList = List<String>.from(attachments)..add(file.path);
      onChanged(newList);
    }
  }

  Future<void> _pickAudio(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.single.path != null) {
      final newList = List<String>.from(attachments)
        ..add(res.files.single.path!);
      onChanged(newList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(context),
              icon: const Icon(Icons.image),
              label: Text(l10n.imageLabel),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _pickAudio(context),
              icon: const Icon(Icons.audiotrack),
              label: Text(l10n.audioLabel),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...attachments.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final a = entry.value;
            final ext = a.split('.').last.toLowerCase();
            if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext)) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Image.file(File(a)),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        final newList = List<String>.from(attachments)
                          ..removeAt(index);
                        onChanged(newList);
                      },
                    ),
                  ),
                ],
              );
            }
            if (['mp3', 'wav'].contains(ext)) {
              return _AudioAttachment(
                path: a,
                onDelete: () {
                  final newList = List<String>.from(attachments)
                    ..removeAt(index);
                  onChanged(newList);
                },
              );
            }
            return ListTile(
              title: Text(a.split('/').last),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  final newList = List<String>.from(attachments)
                    ..removeAt(index);
                  onChanged(newList);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AudioAttachment extends StatefulWidget {
  final String path;
  final VoidCallback? onDelete;
  const _AudioAttachment({required this.path, this.onDelete});

  @override
  State<_AudioAttachment> createState() => _AudioAttachmentState();
}

class _AudioAttachmentState extends State<_AudioAttachment> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_playing) {
        await _player.pause();
      } else {
        await _player.play(DeviceFileSource(widget.path));
      }
      if (!mounted) return;
      setState(() => _playing = !_playing);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.path.split('/').last),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            onPressed: _toggle,
          ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
        ],
      ),
    );
  }
}
