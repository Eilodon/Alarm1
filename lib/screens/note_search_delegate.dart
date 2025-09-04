import 'package:flutter/material.dart';
import '../models/note.dart';

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
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final filtered = notes.where((n) {
      final lower = query.toLowerCase();
      return n.title.toLowerCase().contains(lower) ||
          n.content.toLowerCase().contains(lower);
    }).toList();
    return ListView(
      children: filtered
          .map((n) => ListTile(
                title: Text(n.title),
                subtitle: Text(n.content),
              ))
          .toList(),
    );
  }
}
