import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/command.dart';
import '../widgets/palette_bottom_sheet.dart';

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
  late final List<Command> _commands;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Shortcuts(
      shortcuts: const {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            _OpenPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            _OpenPaletteIntent(),
      },
      child: Actions(
        actions: {
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (intent) {
              _openPalette();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: IndexedStack(index: _currentIndex, children: _screens),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: [
                const BottomNavigationBarItem(
                    icon: Icon(Icons.note), label: 'Notes'),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.alarm),
                  label: 'Reminders',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.mic),
                  label: l10n.voiceToNote,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.smart_toy),
                  label: l10n.chatAI,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: l10n.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
