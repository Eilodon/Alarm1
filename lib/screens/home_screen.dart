import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../pandora_ui/bottom_sheet.dart';
import '../pandora_ui/palette_list_item.dart';
import '../pandora_ui/pandora_snackbar.dart';
import '../pandora_ui/teach_ai_modal.dart';
import '../theme/tokens.dart';
import '../pandora_ui/toolbar_button.dart';

import '../widgets/notes_tab.dart';
import 'chat_screen.dart';
import 'note_list_for_day_screen.dart';
import 'settings_screen.dart';
import 'voice_to_note_screen.dart';

const _durationLong = Duration(milliseconds: 500);

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
  late final List<Command> _commands;

  OverlayEntry? _snackEntry;

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
    _commands = [
      Command(
        title: 'Show Notes',
        action: () => setState(() => _currentIndex = 0),
      ),
      Command(
        title: 'Show Voice to Note',
        action: () => setState(() => _currentIndex = 2),
      ),
      Command(
        title: 'Open Settings',
        action: () => setState(() => _currentIndex = 4),
      ),
    ];
  }

  void _openPalette() {
    showPaletteBottomSheet(context, commands: _commands);
  }

  void _showSnackbar(String text, SnackbarKind kind) {
    _snackEntry?.remove();
    _snackEntry = OverlayEntry(
      builder: (context) {
        final tokens = Theme.of(context).extension<Tokens>()!;
        return Positioned(
          left: tokens.spacing.m,
          right: tokens.spacing.m,
          bottom: tokens.spacing.l,
          child: PandoraSnackbar(
            text: text,
            kind: kind,
            onClose: () => _snackEntry?.remove(),
          ),
        );
      },
    );
    Overlay.of(context).insert(_snackEntry!);
    Future.delayed(_durationLong, () => _snackEntry?.remove());
  }

  void _showPalette() {
    final tokens = Theme.of(context).extension<Tokens>()!;
    PandoraBottomSheet.show(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaletteListItem(
            color: tokens.colors.primary,
            label: 'Primary',
            onTap: () {
              widget.onThemeChanged(tokens.colors.primary);
              Navigator.pop(context);
              _showSnackbar('Theme updated', SnackbarKind.success);
            },
          ),
          PaletteListItem(
            color: tokens.colors.secondary,
            label: 'Secondary',
            onTap: () {
              widget.onThemeChanged(tokens.colors.secondary);
              Navigator.pop(context);
              _showSnackbar('Theme updated', SnackbarKind.success);
            },
          ),
        ],
      ),
    );
  }

  void _openTeachAi() {
    TeachAiModal.show(
      context,
      onSubmit: (_) => _showSnackbar('Thanks for teaching!', SnackbarKind.success),
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
                        label: 'Notes',
                        onPressed: () => setState(() => _currentIndex = 0),
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.alarm),
                        label: 'Reminders',
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
                        label: 'Palette',
                        onPressed: _showPalette,
                      ),
                      ToolbarButton(
                        icon: const Icon(Icons.school),
                        label: 'Teach AI',
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
