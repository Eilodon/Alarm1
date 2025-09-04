import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();
  bool _requireAuth = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _requireAuth = await _settings.loadRequireAuth();
    setState(() {});
  }

  void _pickColor() async {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal
    ];
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn màu chủ đề'),
        content: Wrap(
          children: colors.map((c) {
            return GestureDetector(
              onTap: () {
                widget.onThemeChanged(c);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
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

  void _toggleAuth(bool v) {
    setState(() => _requireAuth = v);
    _settings.saveRequireAuth(v);
  }

  @override
  Widget build(BuildContext context) {
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
          SwitchListTile(
            title: const Text('Bảo vệ bằng vân tay/PIN'),
            value: _requireAuth,
            onChanged: _toggleAuth,
          ),
        ],
      ),
    );
  }
}
