import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Color) onThemeChanged;
  final Function(double) onFontScaleChanged;
  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onFontScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final _settings = SettingsService();

    void _pickColor() async {
      final colors = [Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange, Colors.teal];
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.chooseThemeColor),
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
          title: Text(AppLocalizations.of(context)!.chooseMascot),
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
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
            onTap: () async {
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
                        child: Text(AppLocalizations.of(context)!.cancel)),
                    TextButton(
                        onPressed: () {
                          onFontScaleChanged(temp);
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.save)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
