import 'package:flutter/material.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:notes_reminder_app/features/note/domain/domain.dart';
import 'package:notes_reminder_app/features/note/presentation/note_detail_screen.dart';
import 'package:notes_reminder_app/services/auth_service.dart';
import 'package:notes_reminder_app/widgets/route_transitions.dart';

class NoteSearchDelegate extends SearchDelegate {
  final List<Note> notes;
  NoteSearchDelegate(this.notes);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final filtered = notes.where((n) {
      final lower = query.toLowerCase();
      return n.title.toLowerCase().contains(lower) ||
          n.content.toLowerCase().contains(lower);
    }).toList();
    return ListView(
      children: filtered
          .map((n) => ListTile(
                title: Hero(
                  tag: n.id,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(n.title),
                  ),
                ),
                subtitle: Text(n.content),
                onTap: () async {
                  if (n.locked) {
                    final ok = await AuthService()
                        .authenticate(AppLocalizations.of(context)!);
                    if (!ok) return;
                  }
                  Navigator.push(
                    context,
                    buildSlideFadeRoute(NoteDetailScreen(note: n)),
                  );
                },
              ))
          .toList(),
    );
  }
}
