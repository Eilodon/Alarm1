import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../pandora_ui/result_card.dart';
import '../pandora_ui/toolbar_button.dart';


import '../providers/note_provider.dart';
import '../screens/note_detail_screen.dart';
import '../services/auth_service.dart';

class NotesList extends StatefulWidget {

  final List<Note> notes;
  final int gridCount;

  const NotesList({super.key, required this.notes, this.gridCount = 1});


  final List<Note> notes;

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

    return ResultCard(
      child: Slidable(
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
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => NoteDetailScreen(note: note),
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


    Widget buildItem(BuildContext context, int index) {
      if (index >= notes.length) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final note = notes[index];
      return ResultCard(
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
          subtitle: Text(
            note.alarmTime != null
                ? '${note.content}\n⏰ ${DateFormat.yMd(Localizations.localeOf(context).toString()).add_Hm().format(note.alarmTime!)}'
                : note.content,
          ),
          onTap: () async {
            if (note.locked) {
              final ok = await AuthService().authenticate(
                AppLocalizations.of(context)!,
              );
              if (!ok) return;
            }
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => NoteDetailScreen(note: note),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.pinned) const Icon(Icons.push_pin, size: 20),
              if (!provider.isSynced(note.id))
                const Icon(Icons.sync_problem, color: Colors.orange),
              ToolbarButton(
                icon: const Icon(Icons.delete),
                label: AppLocalizations.of(context)!.delete,
                onPressed: () {
                  final idx = provider.notes.indexWhere((n) => n.id == note.id);
                  if (idx != -1) {
                    provider.removeNoteAt(idx);
                  }
                },
              ),
            ],
          ),
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                Share.share('${note.title}\n${note.content}');
              },
              icon: Icons.share,
              label: AppLocalizations.of(context)!.share,
            ),
            SlidableAction(
              backgroundColor: Colors.red,
              onPressed: (_) {
                final idx = provider.notes.indexWhere((n) => n.id == note.id);
                if (idx != -1) {
                  provider.removeNoteAt(idx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.noteDeleted),
                      action: SnackBarAction(
                        label: AppLocalizations.of(context)!.undo,
                        onPressed: () => provider.addNote(note),
                      ),
                    ),
                  );
                }
              },
              icon: Icons.delete,
              label: AppLocalizations.of(context)!.delete,
            ),
          ],
        ),
      );
    }

    if (widget.gridCount > 1) {
      return GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridCount,
          childAspectRatio: 3,
        ),
        itemCount: itemCount,
        itemBuilder: buildItem,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: buildItem,

    );
  }
}

