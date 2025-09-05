import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  final Function(double) onFontScaleChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onFontScaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  bool _requireAuth = false;

  @override
  void initState() {
    super.initState();
    _settings.loadRequireAuth().then((v) {
      if (mounted) {
        setState(() => _requireAuth = v);
      }
    });
  }

  Future<void> _pickColor() async {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseThemeColor),
        content: Wrap(
          children: colors.map((c) {
            return GestureDetector(
              onTap: () {
                widget.onThemeChanged(c);
                _settings.saveThemeColor(c);
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

  Future<void> _pickMascot() async {
    final paths = [
      'assets/lottie/mascot.json',
      'assets/lottie/mascot2.json',
      'assets/lottie/mascot3.json',
    ];
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseMascot),
        content: Wrap(
          children: paths.map((p) {
            return GestureDetector(
              onTap: () {
                _settings.saveMascotPath(p);
                Navigator.pop(context);
              },
              child: Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.all(8),
                child: Lottie.asset(p),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _changeFontScale() async {
    final current = await _settings.loadFontScale();
    double temp = current;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.fontSize),
        content: StatefulBuilder(
          builder: (context, setState) => Slider(
            min: 0.8,
            max: 2.0,
            divisions: 12,
            value: temp,
            label: temp.toStringAsFixed(1),
            onChanged: (v) => setState(() => temp = v),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.onFontScaleChanged(temp);
              _settings.saveFontScale(temp);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.changeThemeColor),
            onTap: _pickColor,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.changeMascot),
            onTap: _pickMascot,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.fontSize),
            onTap: _changeFontScale,
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.requireAuth),
            value: _requireAuth,
            onChanged: _toggleAuth,
          ),
        ],
      ),
    );
  }
}
