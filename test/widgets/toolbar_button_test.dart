import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_reminder_app/widgets/toolbar_button.dart';

import 'package:notes_reminder_app/theme/tokens.dart';

void main() {
  testWidgets('ToolbarButton enabled state respects touch target',
      (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(

        theme: ThemeData(extensions: const [Tokens.light]),

        home: ToolbarButton(
          icon: const Icon(Icons.add),
          label: 'Add',
          onPressed: () {
            pressed = true;
          },
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);


    expect(opacityWidget.opacity, 1.0);


    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isTrue);
  });

  testWidgets('ToolbarButton disabled state', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(

        theme: ThemeData(extensions: const [Tokens.light]),

        home: ToolbarButton(
          icon: const Icon(Icons.add),
          label: 'Add',
          onPressed: () {
            pressed = true;
          },
          state: 'disabled',
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);


    final opacityWidget = tester.widget<Opacity>(
      find.ancestor(of: find.byType(ElevatedButton), matching: find.byType(Opacity)),
    );
    expect(opacityWidget.opacity, 0.5);


    final style = button.style!;
    final context = tester.element(find.byType(ToolbarButton));
    final tokens = Theme.of(context).extension<Tokens>()!;
    final bg = style.backgroundColor!.resolve({MaterialState.disabled});
    expect(bg, tokens.colors.neutral300);

    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isFalse);
  });
}
