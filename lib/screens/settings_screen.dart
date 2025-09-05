import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final _settings = SettingsService();

  void _pickColor() async {
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

  void _changeFontScale() async {
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
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.changeThemeColor),
            onTap: _pickColor,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.fontSize),
            onTap: _changeFontScale,
          ),
        ],
      ),
    );
  }
}
