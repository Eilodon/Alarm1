import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../pandora_ui/bottom_sheet.dart';
import '../pandora_ui/palette_list_item.dart';
import '../pandora_ui/pandora_snackbar.dart';
import '../pandora_ui/teach_ai_modal.dart';
import '../pandora_ui/tokens.dart';
import '../pandora_ui/toolbar_button.dart';
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
  }

  void _showSnackbar(String text, SnackbarKind kind) {
    _snackEntry?.remove();
    _snackEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: PandoraTokens.spacingM,
        right: PandoraTokens.spacingM,
        bottom: PandoraTokens.spacingL,
        child: PandoraSnackbar(
          text: text,
          kind: kind,
          onClose: () => _snackEntry?.remove(),
        ),
      ),
    );
    Overlay.of(context).insert(_snackEntry!);
    Future.delayed(PandoraTokens.durationLong, () => _snackEntry?.remove());
  }

  void _showPalette() {
    PandoraBottomSheet.show(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaletteListItem(
            color: PandoraTokens.primary,
            label: 'Primary',
            onTap: () {
              widget.onThemeChanged(PandoraTokens.primary);
              Navigator.pop(context);
              _showSnackbar('Theme updated', SnackbarKind.success);
            },
          ),
          PaletteListItem(
            color: PandoraTokens.secondary,
            label: 'Secondary',
            onTap: () {
              widget.onThemeChanged(PandoraTokens.secondary);
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
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(PandoraTokens.spacingS),
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
        ],
      ),
    );
  }
}
