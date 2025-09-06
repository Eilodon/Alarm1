import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/pandora_ui/toolbar_button.dart';
import 'package:notes_reminder_app/pandora_ui/tokens.dart';

void main() {
  testWidgets('ToolbarButton enabled state', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ToolbarButton(
          icon: const Icon(Icons.add),
          label: 'Add',
          onPressed: () {
            pressed = true;
          },
        ),
      ),
    );

    final opacityWidget = tester.widget<Opacity>(
      find.ancestor(of: find.byType(ElevatedButton), matching: find.byType(Opacity)),
    );

    expect(opacityWidget.opacity, PandoraTokens.opacityEnabled);

    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isTrue);
  });

  testWidgets('ToolbarButton disabled state', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ToolbarButton(
          icon: const Icon(Icons.add),
          label: 'Add',
          onPressed: () {
            pressed = true;
          },
          disabled: true,
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    final opacityWidget = tester.widget<Opacity>(
      find.ancestor(of: find.byType(ElevatedButton), matching: find.byType(Opacity)),
    );
    expect(opacityWidget.opacity, PandoraTokens.opacityDisabled);

    final style = button.style!;
    final shape = style.shape!.resolve({MaterialState.disabled}) as RoundedRectangleBorder;
    expect(shape.side.color, PandoraTokens.neutral200);

    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isFalse);
  });
}
