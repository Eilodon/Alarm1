import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../widgets/add_note_dialog.dart';
import 'note_detail_screen.dart';
import 'note_list_for_day_screen.dart';
import 'note_search_delegate.dart';
import 'settings_screen.dart';
import 'voice_to_note_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Color) onThemeChanged;
  final Function(double) onFontScaleChanged;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onFontScaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mascotPath = 'assets/lottie/mascot.json';
  final DateTime _today = DateTime.now();
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadMascot();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
    });
  }

  Future<void> _loadMascot() async {
    _mascotPath = await SettingsService().loadMascotPath();
    if (mounted) setState(() {});
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (_) => const AddNoteDialog(),
    );
  }

  List<Note> _notesForDay(DateTime day, List<Note> notes) {
    return notes
        .where(
          (n) =>
              n.alarmTime != null &&
              n.alarmTime!.year == day.year &&
              n.alarmTime!.month == day.month &&
              n.alarmTime!.day == day.day,
        )
        .toList();
  }

  Widget _buildNotesList(List<Note> notes) {
    if (notes.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noNotes));
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          child: ListTile(
            leading: note.locked ? const Icon(Icons.lock) : null,
            title: Text(note.title),
            subtitle: Text(
              note.alarmTime != null
                  ? '${note.content}\n⏰ ${DateFormat.yMd(
                          Localizations.localeOf(context).toString(),
                        )
                          .add_Hm()
                          .format(note.alarmTime!)}'
                  : note.content,
            ),
            onTap: () async {
              if (note.locked) {
                final ok = await AuthService()
                    .authenticate(AppLocalizations.of(context)!);
                if (!ok) return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              tooltip: AppLocalizations.of(context)!.delete,
              onPressed: () {
                final note = context.read<NoteProvider>().notes[index];
                context.read<NoteProvider>().removeNoteAt(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.noteDeleted,
                    ),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.undo,
                      onPressed: () =>
                          context.read<NoteProvider>().addNote(note),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;
    final tags = notes.expand((n) => n.tags).toSet().toList();
    final filteredNotes = _selectedTag == null
        ? notes
        : notes.where((n) => n.tags.contains(_selectedTag!)).toList();
    final weekDays = List.generate(7, (i) => _today.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.label),
            onSelected: (value) {
              setState(() {
                _selectedTag = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem<String?>(
                value: null,
                child: Text(AppLocalizations.of(context)!.allTags),
              ),
              ...tags.map(
                (t) => PopupMenuItem<String?>(
                  value: t,
                  child: Text(t),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate:
                  NoteSearchDelegate(context.read<NoteProvider>().notes),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VoiceToNoteScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settingsTooltip,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                    onFontScaleChanged: widget.onFontScaleChanged,
                  ),
                ),
              );
              _loadMascot();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(width: 140, height: 140, child: Lottie.asset(_mascotPath)),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              itemBuilder: (context, i) {
                final d = weekDays[i];
                final hasNotes = _notesForDay(d, filteredNotes).isNotEmpty;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteListForDayScreen(date: d),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: hasNotes ? Colors.orange : Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat.E(Localizations.localeOf(context).toString()).format(d)),
                        Text('${d.day}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildNotesList(filteredNotes)),
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
