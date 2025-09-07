import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../providers/note_provider.dart';
import '../services/settings_service.dart';
import '../screens/note_search_delegate.dart';
import '../screens/voice_to_note_screen.dart';
import '../screens/settings_screen.dart';
import '../pandora_ui/toolbar_button.dart';
import 'add_note_dialog.dart';
import 'tag_filtered_notes_list.dart';

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

  Future<String> _loadMascot() async {
    return SettingsService().loadMascotPath();
  }

  void _addNote() {
    showDialog(context: context, builder: (_) => const AddNoteDialog());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();

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
              delegate: NoteSearchDelegate(context.read<NoteProvider>().notes),
            ),
          ),
          ToolbarButton(
            icon: const Icon(Icons.mic),
            label: AppLocalizations.of(context)!.voiceToNote,
            onPressed: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const VoiceToNoteScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ToolbarButton(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
            onPressed: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                    onFontScaleChanged: widget.onFontScaleChanged,
                    onThemeModeChanged: widget.onThemeModeChanged,
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
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
              if (value == 'backup') {
                final ok = await context.read<NoteProvider>().backupNow();
                if (!mounted) return;
                final l10n = AppLocalizations.of(context)!;
                if (ok) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.notesExported)));
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'backup',
                child: Text(AppLocalizations.of(context)!.backupNow),
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
          const Expanded(child: TagFilteredNotesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: AppLocalizations.of(context)!.addNoteTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
