import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


import '../features/note/presentation/note_provider.dart';
import '../features/settings/data/settings_service.dart';

import '../features/note/presentation/note_search_delegate.dart';
import '../features/note/presentation/voice_to_note_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../pandora_ui/palette_bottom_sheet.dart';
import '../pandora_ui/teach_ai_modal.dart';
import '../features/note/domain/domain.dart';
import 'add_note_dialog.dart';
import 'tag_filtered_notes_list.dart';
import 'route_transitions.dart';

class NotesTab extends StatefulWidget {
  final Function(Color) onThemeChanged;
  final Function(double) onFontScaleChanged;
  final Function(ThemeMode) onThemeModeChanged;

  const NotesTab({
    super.key,
    required this.onThemeChanged,
    required this.onFontScaleChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  late Future<String> _mascotFuture;
  static const _platform = MethodChannel('notes_reminder_app/actions');

  @override
  void initState() {
    super.initState();
    _mascotFuture = _loadMascot();
    _platform.setMethodCallHandler((call) async {
      if (call.method == 'voiceToNote') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VoiceToNoteScreen(autoStart: true),
          ),
        );
      }
    });
  }

  Future<String> _loadMascot() => SettingsServiceImpl().loadMascotPath();

  void _addNote() {
    showDialog(context: context, builder: (_) => const AddNoteDialog());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a grid on wider layouts. One column on phones, two on tablets
        // and more as space allows.
        final gridCount = (constraints.maxWidth ~/ 300).clamp(1, 4);
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.appTitle),
            actions: [
              ValueListenableBuilder<SyncStatus>(
                valueListenable: provider.syncStatus,
                builder: (context, status, _) {
                  final l10n = AppLocalizations.of(context)!;
                  String text;
                  switch (status) {
                    case SyncStatus.syncing:
                      text = l10n.syncStatusSyncing;
                      break;
                    case SyncStatus.error:
                      text = l10n.syncStatusError;
                      break;
                    case SyncStatus.idle:
                    default:
                      text = l10n.syncStatusIdle;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(child: Text(text)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => showSearch(
                  context: context,
                  delegate: NoteSearchDelegate(
                    context.read<NoteProvider>().notes,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic),
                tooltip: AppLocalizations.of(context)!.voiceToNote,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    buildSlideFadeRoute(const VoiceToNoteScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: AppLocalizations.of(context)!.settings,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    buildSlideFadeRoute(
                      SettingsScreen(
                        onThemeChanged: widget.onThemeChanged,
                        onFontScaleChanged: widget.onFontScaleChanged,
                        onThemeModeChanged: widget.onThemeModeChanged,
                        settingsService: SettingsServiceImpl(),
                      ),
                    ),
                  );
                  if (mounted) {
                    setState(() {
                      _mascotFuture = _loadMascot();
                    });
                  }
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final l10n = AppLocalizations.of(context)!;
                  if (value == 'backup') {
                    final ok = await context.read<NoteProvider>().backupNow();
                    if (!mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.notesExported)),
                      );
                    }
                  } else if (value == 'palette') {
                    await showPaletteBottomSheet(
                      context,
                      commands: [
                        Command(
                          title: l10n.voiceToNote,
                          action: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VoiceToNoteScreen(),
                            ),
                          ),
                        ),
                        Command(
                          title: l10n.settings,
                          action: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                onThemeChanged: widget.onThemeChanged,
                                onFontScaleChanged: widget.onFontScaleChanged,
                                onThemeModeChanged: widget.onThemeModeChanged,
                                settingsService: SettingsServiceImpl(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (value == 'teachAi') {
                    await TeachAiModal.show(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'backup',
                    child: Text(AppLocalizations.of(context)!.backupNow),
                  ),
                  PopupMenuItem(
                    value: 'palette',
                    child: Text(AppLocalizations.of(context)!.palette),
                  ),
                  PopupMenuItem(
                    value: 'teachAi',
                    child: Text(AppLocalizations.of(context)!.teachAi),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: 140,
                height: 140,
                child: FutureBuilder<String>(
                  future: _mascotFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done ||
                        !snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final path = snapshot.data!;
                    if (!path.endsWith('.json')) {
                      return Image.asset(path);
                    }
                    return RepaintBoundary(child: Lottie.asset(path));
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: TagFilteredNotesList(gridCount: gridCount)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addNote,
            tooltip: AppLocalizations.of(context)!.addNoteTooltip,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
