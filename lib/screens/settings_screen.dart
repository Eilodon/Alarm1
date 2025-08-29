import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Color) onThemeChanged;
  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final _settings = SettingsService();

    void _pickColor() async {
      final colors = [Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange, Colors.teal];
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Chọn màu chủ đề'),
          content: Wrap(
            children: colors.map((c) {
              return GestureDetector(
                onTap: () {
                  onThemeChanged(c);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    void _pickMascot() async {
      final options = [
        'assets/lottie/mascot.json',
        'assets/lottie/mascot2.json',
        'assets/lottie/mascot3.json'
      ];
      await showDialog(
        context: context,
        builder: (_) => SimpleDialog(
          title: const Text('Chọn mascot'),
          children: options.map((path) {
            return SimpleDialogOption(
              onPressed: () {
                _settings.saveMascotPath(path);
                Navigator.pop(context);
              },
              child: Text(path.split('/').last),
            );
          }).toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Đổi màu giao diện'),
            onTap: _pickColor,
          ),
          ListTile(
            title: const Text('Thay mascot'),
            onTap: _pickMascot,
          ),
        ],
      ),
    );
  }
}
