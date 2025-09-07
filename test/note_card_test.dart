import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/widgets/note_card.dart';

void main() {
  testWidgets('NoteCard displays its child inside a Card', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: NoteCard(
        child: ListTile(
          title: Text('hi'),
        ),
      ),
    ));

    expect(find.text('hi'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });
}

