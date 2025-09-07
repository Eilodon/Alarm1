import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';

import '../providers/note_provider.dart';
import '../screens/note_detail_screen.dart';
import '../services/auth_service.dart';
import '../pandora_ui/toolbar_button.dart';
import 'note_card.dart';


/// Displays a scrollable list of notes. When [gridCount] is greater than 1 a
/// grid layout is used instead of a traditional list.
class NotesList extends StatefulWidget {
  const NotesList({super.key, required this.notes, this.gridCount = 1});

  /// Notes to display.
  final List<Note> notes;


  /// Number of columns to show. A value greater than 1 enables a grid layout.
  final int gridCount;

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DateTime? _lastFetched;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialFetch());
  }

  Future<void> _initialFetch() async {
    final provider = context.read<NoteProvider>();
    if (provider.notes.isNotEmpty) {
      setState(() {
        _lastFetched = provider.notes.last.updatedAt;
        _hasMore = provider.notes.length >= _pageSize;
      });
    } else {
      final notes = await provider.fetchNotesPage(null, _pageSize);
      if (!mounted) return;
      setState(() {
        if (notes.isNotEmpty) {
          _lastFetched = notes.last.updatedAt;
          _hasMore = notes.length == _pageSize;
        }
      });
    }
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    final notes = await context
        .read<NoteProvider>()
        .fetchNotesPage(_lastFetched, _pageSize);

    if (!mounted) return;
    setState(() {
      _isLoadingMore = false;
      if (notes.isNotEmpty) {
        _lastFetched = notes.last.updatedAt;
      }
      if (notes.length < _pageSize) {
        _hasMore = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildNoteTile(
      BuildContext context, Note note, NoteProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final subtitle = note.alarmTime != null
        ? '${note.content}\n⏰ ${DateFormat.yMd(locale).add_Hm().format(note.alarmTime!)}'
        : note.content;

    return NoteCard(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              Share.share('${note.title}\n${note.content}');
            },
            icon: Icons.share,
            label: l10n.share,
          ),
          SlidableAction(
            backgroundColor: Colors.red,
            onPressed: (_) {
              final idx = provider.notes.indexWhere((n) => n.id == note.id);
              if (idx != -1) {
                provider.removeNoteAt(idx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.noteDeleted),
                    action: SnackBarAction(
                      label: l10n.undo,
                      onPressed: () => provider.addNote(note),
                    ),
                  ),
                );
              }
            },
            icon: Icons.delete,
            label: l10n.delete,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(note.color),
          ),
          child: note.locked
              ? const Icon(Icons.lock, size: 16, color: Colors.white)
              : null,
        ),
        title: Text(note.title),
        subtitle: Text(subtitle),
        onTap: () async {
          if (note.locked) {
            final ok = await AuthService().authenticate(l10n);
            if (!ok) return;
          }
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => NoteDetailScreen(note: note),
            ),
          );
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.check),
                    title: Text(l10n.markDone),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await provider.updateNote(
                        note.copyWith(done: true, active: false),
                        l10n,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.alarm),
                    title: Text(l10n.setReminder),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                        initialDate: DateTime.now(),
                      );
                      if (date == null) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time == null) return;
                      final alarmTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      await provider.updateNote(
                        note.copyWith(alarmTime: alarmTime),
                        l10n,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: Text(l10n.share),
                    onTap: () {
                      Navigator.pop(ctx);
                      Share.share('${note.title}\n${note.content}');
                    },
                  ),
                ],
              ),
            ),
          );
        },

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.pinned) const Icon(Icons.push_pin, size: 20),
            if (!provider.isSynced(note.id))
              const Icon(Icons.sync_problem, color: Colors.orange),
            ToolbarButton(
              icon: const Icon(Icons.delete),
              label: l10n.delete,
              onPressed: () {

                final idx =
                    provider.notes.indexWhere((n) => n.id == note.id);

                if (idx != -1) {
                  provider.removeNoteAt(idx);
                }
              },
            ),
          ],
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.notes;
    if (notes.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noNotes));
    }

    final provider = context.watch<NoteProvider>();
    final itemCount = notes.length + (_isLoadingMore ? 1 : 0);

    Widget builder(BuildContext context, int index) {
      if (index >= notes.length) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final note = notes[index];
      return _buildNoteTile(context, note, provider);
    }

    if (widget.gridCount > 1) {
      return GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridCount,
          childAspectRatio: 3,
        ),
        itemCount: itemCount,
        itemBuilder: builder,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,

      itemBuilder: builder,

    );
  }
}

