import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/settings_service.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/notes_list.dart';
import '../widgets/tag_filter_menu.dart';
import 'note_list_for_day_screen.dart';
import 'note_search_delegate.dart';
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
  String _mascotPath = 'assets/lottie/mascot.json';
  final DateTime _today = DateTime.now();
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadMascot();
  }

  Future<void> _loadMascot() async {
    _mascotPath = await SettingsService().loadMascotPath();
    if (mounted) setState(() {});
  }

  void _addNote() {
    showDialog(context: context, builder: (_) => const AddNoteDialog());
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
          TagFilterMenu(
            tags: tags,
            selectedTag: _selectedTag,
            onSelected: (value) {
              setState(() {
                _selectedTag = value;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: NoteSearchDelegate(context.read<NoteProvider>().notes),
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
                    onThemeModeChanged: widget.onThemeModeChanged,
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
                        Text(
                          DateFormat.E(
                            Localizations.localeOf(context).toString(),
                          ).format(d),
                        ),
                        Text('${d.day}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: NotesList(notes: filteredNotes)),
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
