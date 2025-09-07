import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    // Use a layout builder to switch between mobile and tablet/desktop
    // scaffolds depending on the available width.
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

        // Mobile layout with toolbar buttons at the bottom.
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
            ],
          ),
        );
      },
    );
  }
}
