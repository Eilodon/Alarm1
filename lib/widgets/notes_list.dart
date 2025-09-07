import 'package:flutter/material.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:notes_reminder_app/features/note/domain/domain.dart';

import 'package:notes_reminder_app/features/note/presentation/note_provider.dart';
import 'package:notes_reminder_app/features/note/presentation/note_detail_screen.dart';
import 'package:notes_reminder_app/services/auth_service.dart';
import 'package:notes_reminder_app/widgets/note_card.dart';

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

    final notes = await context.read<NoteProvider>().fetchNotesPage(
      _lastFetched,
      _pageSize,
    );

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

  Future<void> _refreshNotes(NoteProvider provider) async {
    final notes = await provider.fetchNotesPage(null, _pageSize);
    if (!mounted) return;
    setState(() {
      _lastFetched = notes.isNotEmpty ? notes.last.updatedAt : null;
      _hasMore = notes.length == _pageSize;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _deleteNote(
    BuildContext context,
    Note note,
    NoteProvider provider,
    AppLocalizations l10n,
  ) {
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
  }

  Widget _buildNoteTile(
    BuildContext context,
    Note note,
    NoteProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final subtitle = note.alarmTime != null
        ? '${note.content}\n⏰ ${DateFormat.yMd(locale).add_Hm().format(note.alarmTime!)}'
        : note.content;
    final noteColor = Color(note.color);
    final lockIconColor =
        ThemeData.estimateBrightnessForColor(noteColor) == Brightness.dark
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

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
            backgroundColor: Theme.of(context).colorScheme.error,
            onPressed: (_) => _deleteNote(context, note, provider, l10n),
            icon: Icons.delete,
            label: l10n.delete,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: noteColor),
          child: note.locked
              ? Icon(Icons.lock, size: 16, color: lockIconColor)
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

            MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
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
                        lastDate: DateTime.now().add(const Duration(days: 365)),
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
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(l10n.delete),
                    onTap: () {
                      Navigator.pop(ctx);
                      _deleteNote(context, note, provider, l10n);
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
              Icon(
                Icons.sync_problem,
                color: Theme.of(context).colorScheme.tertiary,
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
      return RefreshIndicator(
        onRefresh: () => _refreshNotes(provider),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridCount,
            childAspectRatio: 3,
          ),
          itemCount: itemCount,
          itemBuilder: builder,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshNotes(provider),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        itemBuilder: builder,
      ),
    );
  }
}
