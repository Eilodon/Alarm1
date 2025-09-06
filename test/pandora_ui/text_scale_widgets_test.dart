import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/pandora_ui/hint_chip.dart';
import 'package:notes_reminder_app/pandora_ui/palette_list_item.dart';
import 'package:notes_reminder_app/pandora_ui/toolbar_button.dart';
import 'package:notes_reminder_app/pandora_ui/tokens.dart';

void main() {
  testWidgets('HintChip scales with textScaleFactor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 1.0),
          child: HintChip(label: 'Hint', onPressed: () {}),
        ),
      ),
    );
    await tester.pump();
    final size1 = tester.getSize(find.text('Hint'));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 2.0),
          child: HintChip(label: 'Hint', onPressed: () {}),
        ),
      ),
    );
    await tester.pump();
    final size2 = tester.getSize(find.text('Hint'));
    final chipSize = tester.getSize(find.byType(Ink));

    expect(size2.height, greaterThan(size1.height));
    expect(chipSize.height, greaterThanOrEqualTo(PandoraTokens.touchTarget));
  });

  testWidgets('ToolbarButton scales with textScaleFactor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 1.0),
          child: ToolbarButton(
            icon: const Icon(Icons.add),
            label: 'Add',
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    final size1 = tester.getSize(find.text('Add'));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 2.0),
          child: ToolbarButton(
            icon: const Icon(Icons.add),
            label: 'Add',
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    final size2 = tester.getSize(find.text('Add'));
    final buttonSize = tester.getSize(find.byType(ElevatedButton));

    expect(size2.height, greaterThan(size1.height));
    expect(buttonSize.height, greaterThanOrEqualTo(PandoraTokens.touchTarget));
  });

  testWidgets('PaletteListItem scales with textScaleFactor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 1.0),
          child: PaletteListItem(color: Colors.red, label: 'Red'),
        ),
      ),
    );
    await tester.pump();
    final size1 = tester.getSize(find.text('Red'));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 2.0),
          child: PaletteListItem(color: Colors.red, label: 'Red'),
        ),
      ),
    );
    await tester.pump();
    final size2 = tester.getSize(find.text('Red'));
    final itemSize = tester.getSize(find.byType(ListTile));

    expect(size2.height, greaterThan(size1.height));
    expect(itemSize.height, greaterThanOrEqualTo(PandoraTokens.touchTarget));
  });
}
