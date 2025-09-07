import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../pandora_ui/bottom_sheet.dart';
import '../pandora_ui/palette_list_item.dart';
import '../pandora_ui/palette_bottom_sheet.dart';
import '../pandora_ui/snackbar.dart';
import '../pandora_ui/teach_ai_modal.dart';
import '../pandora_ui/toolbar_button.dart';
import '../models/command.dart';
import '../models/security_cue.dart';
import '../theme/tokens.dart';

import '../widgets/notes_tab.dart';
import 'chat_screen.dart';
import 'note_list_for_day_screen.dart';
import 'settings_screen.dart';
import 'voice_to_note_screen.dart';


class HomeScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  final Function(double) onFontScaleChanged;
  final Function(ThemeMode) onThemeModeChanged;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onFontScaleChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late List<Command> _commands;

  List<Command> _buildCommands(AppLocalizations l10n) {
    return [
      Command(
        title: l10n.showNotes,
        action: () => setState(() => _currentIndex = 0),
      ),
      Command(
        title: l10n.showVoiceToNote,
        action: () => setState(() => _currentIndex = 2),
      ),
      Command(
        title: l10n.openSettings,
        action: () => setState(() => _currentIndex = 4),
      ),
    ];
  }


  @override
  void initState() {
    super.initState();
    _screens = [
      NotesTab(
        onThemeChanged: widget.onThemeChanged,
        onFontScaleChanged: widget.onFontScaleChanged,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      NoteListForDayScreen(date: DateTime.now()),
      const VoiceToNoteScreen(),
      const ChatScreen(initialMessage: ''),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
        onFontScaleChanged: widget.onFontScaleChanged,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _commands = _buildCommands(l10n);
  }

  void _openPalette() {
    showPaletteBottomSheet(context, commands: _commands);
  }

  void _showSnackbar(String text) {
    showSimpleSnackBar(context, text, SecurityCue.onDevice);
  }

  void _showPalette() {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<Tokens>()!;
    PandoraBottomSheet.show(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaletteListItem(
            color: tokens.colors.primary,
            label: l10n.primary,
            onTap: () {
              widget.onThemeChanged(tokens.colors.primary);
              Navigator.pop(context);
              _showSnackbar(l10n.themeUpdated);
            },
          ),
          PaletteListItem(
            color: tokens.colors.secondary,
            label: l10n.secondary,
            onTap: () {
              widget.onThemeChanged(tokens.colors.secondary);
              Navigator.pop(context);
              _showSnackbar(l10n.themeUpdated);
            },
          ),
        ],
      ),
    );
  }

  void _openTeachAi() {
    TeachAiModal.show(
      context,
      onSubmit: (_) => _showSnackbar('Thanks for teaching!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<Tokens>()!;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.s),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ToolbarButton(
                        icon: const Icon(Icons.note),
                        label: l10n.notes,
                        onPressed: () => setState(() => _currentIndex = 0),
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.alarm),
                        label: l10n.reminders,
                        onPressed: () => setState(() => _currentIndex = 1),
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.mic),
                        label: l10n.voiceToNote,
                        onPressed: () => setState(() => _currentIndex = 2),
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.smart_toy),
                        label: l10n.chatAI,
                        onPressed: () => setState(() => _currentIndex = 3),
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.settings),
                        label: l10n.settings,
                        onPressed: () => setState(() => _currentIndex = 4),
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.palette),
                        label: l10n.palette,
                        onPressed: _showPalette,
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.school),
                        label: l10n.teachAi,
                        onPressed: _openTeachAi,
                      ),
                    ],
                  ),
                ),
              ),

            ),
          ),
        ),
      ),
    );
  }
}
