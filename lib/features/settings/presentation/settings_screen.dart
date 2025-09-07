import 'package:flutter/material.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math' as math;


import '../domain/settings_service.dart';

import 'package:alarm_domain/alarm_domain.dart';

import 'package:provider/provider.dart';
import '../../note/presentation/note_provider.dart';


class SettingsScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  final Function(double) onFontScaleChanged;
  final Function(ThemeMode) onThemeModeChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onFontScaleChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsService _settings;
  final NoteRepository _noteRepository = NoteRepositoryImpl();
  bool _requireAuth = false;

  ThemeMode _themeMode = ThemeMode.system;

  BackupFormat _backupFormat = BackupFormat.json;

  @override
  void initState() {
    super.initState();
    _settings = context.read<SettingsService>();
    _settings.loadRequireAuth().then((v) {
      if (mounted) {
        setState(() => _requireAuth = v);
      }
    });

    _settings.loadBackupFormat().then((v) {
      if (mounted) {
        setState(() => _backupFormat = v);
      }
    });

    _settings.loadThemeMode().then((v) {
      if (mounted) {
        setState(() => _themeMode = v);
        widget.onThemeModeChanged(_themeMode);
      }
    });
  }

  Future<void> _pickColor() async {
    Color temp = Theme.of(context).colorScheme.primary;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseThemeColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: temp,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.onThemeChanged(temp);
              _settings.saveThemeColor(temp);
              _warnIfLowContrast(temp);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _warnIfLowContrast(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);

    final foreground =
        brightness == Brightness.dark ? Colors.white : Colors.black;

    final l1 = color.computeLuminance();
    final l2 = foreground.computeLuminance();
    final ratio = (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
    if (ratio < 4.5) {
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.lowContrastWarning)));

    }
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

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged(_themeMode);
    _settings.saveThemeMode(_themeMode);
  }

  String _themeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      default:
        return l10n.system;
    }
  }

  Future<void> _exportNotes() async {
    final l10n = AppLocalizations.of(context)!;
    final success = await _noteRepository.exportNotes(
      l10n,
      format: _backupFormat,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.notesExported
              : l10n.errorWithMessage('Failed to export notes'),
        ),
      ),
    );
  }

  Future<void> _importNotes() async {
    final l10n = AppLocalizations.of(context)!;
    final notes = await _noteRepository.importNotes(
      l10n,
      format: _backupFormat,
    );
    if (!mounted) return;
    if (notes.isNotEmpty) {
      await context.read<NoteProvider>().loadNotes();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.notesImported)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithMessage('Failed to import notes')),
        ),
      );
    }
  }

  String _formatLabel(BackupFormat f, AppLocalizations l10n) {
    switch (f) {
      case BackupFormat.json:
        return l10n.formatJson;
      case BackupFormat.pdf:
        return l10n.formatPdf;
      case BackupFormat.md:
        return l10n.formatMarkdown;
    }
  }

  Future<void> _pickFormat() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<BackupFormat>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(l10n.backupFormat),
        children: BackupFormat.values
            .map(
              (f) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, f),
                child: Text(_formatLabel(f, l10n)),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      setState(() => _backupFormat = selected);
      _settings.saveBackupFormat(selected);
    }
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
            title: Text(AppLocalizations.of(context)!.changeMascot),
            onTap: _pickMascot,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.backupFormat),
            subtitle: Text(
              _formatLabel(_backupFormat, AppLocalizations.of(context)!),
            ),
            onTap: _pickFormat,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.fontSize),
            onTap: _changeFontScale,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.themeMode),
            subtitle: Text(
              _themeModeLabel(_themeMode, AppLocalizations.of(context)!),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: _themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  _setThemeMode(mode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(AppLocalizations.of(context)!.light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(AppLocalizations.of(context)!.dark),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(AppLocalizations.of(context)!.system),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.exportNotes),
            onTap: _exportNotes,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.importNotes),
            onTap: _importNotes,
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
