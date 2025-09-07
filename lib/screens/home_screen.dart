import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/notes_tab.dart';
import 'chat_screen.dart';
import 'note_list_for_day_screen.dart';
import 'settings_screen.dart';
import 'voice_to_note_screen.dart';
import '../models/command.dart';
import '../pandora_ui/palette_bottom_sheet.dart';
import '../pandora_ui/teach_ai_modal.dart';


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

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {

        // Wide layouts use a navigation rail with the content in a row.

        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _currentIndex = index),

                  labelType: NavigationRailLabelType.all,

                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.note),
                      label: Text(l10n.notes),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.alarm),
                      label: Text(l10n.reminders),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.mic),
                      label: Text(l10n.voiceToNote),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.smart_toy),
                      label: Text(l10n.chatAI),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.settings),
                    ),
                  ],

                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.palette),
                        onPressed: _showPalette,
                        tooltip: l10n.palette,
                      ),
                      IconButton(
                        icon: const Icon(Icons.school),
                        onPressed: _openTeachAi,
                        tooltip: l10n.teachAi,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile layout with a bottom navigation bar.
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (index < _screens.length) {
                setState(() => _currentIndex = index);
              } else if (index == _screens.length) {
                _showPalette();
                setState(() {});
              } else if (index == _screens.length + 1) {
                _openTeachAi();
                setState(() {});
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.note),
                label: l10n.notes,
              ),
              NavigationDestination(
                icon: const Icon(Icons.alarm),
                label: l10n.reminders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.mic),
                label: l10n.voiceToNote,
              ),
              NavigationDestination(
                icon: const Icon(Icons.smart_toy),
                label: l10n.chatAI,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings),
                label: l10n.settings,
              ),
              NavigationDestination(
                icon: const Icon(Icons.palette),
                label: l10n.palette,
              ),
              NavigationDestination(
                icon: const Icon(Icons.school),
                label: l10n.teachAi,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPalette() async {
    final l10n = AppLocalizations.of(context)!;
    await showPaletteBottomSheet(
      context,
      commands: [
        Command(
          title: l10n.voiceToNote,
          action: () => setState(() => _currentIndex = 2),
        ),
        Command(
          title: l10n.settings,
          action: () => setState(() => _currentIndex = 4),
        ),
      ],
    );
  }

  Future<void> _openTeachAi() {
    return TeachAiModal.show(context);
  }
}
