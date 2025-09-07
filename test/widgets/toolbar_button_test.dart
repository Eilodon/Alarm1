import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/pandora_ui/toolbar_button.dart';
import 'package:notes_reminder_app/pandora_ui/tokens.dart';
import 'package:notes_reminder_app/theme/tokens.dart';

void main() {
  testWidgets('ToolbarButton enabled state respects touch target',
      (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Tokens.light.colors.primary,
            background: Tokens.light.colors.background,
            surface: Tokens.light.colors.surface,
          ),
          fontFamily: Tokens.light.typography.fontFamily,
          useMaterial3: true,
          extensions: const [Tokens.light],
        ),
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

    final size = tester.getSize(find.byType(ElevatedButton));
    expect(size.height >= PandoraTokens.touchTarget, isTrue);
    expect(size.width >= PandoraTokens.touchTarget, isTrue);

    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isTrue);
  });

  testWidgets('ToolbarButton disabled state', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Tokens.light.colors.primary,
            background: Tokens.light.colors.background,
            surface: Tokens.light.colors.surface,
          ),
          fontFamily: Tokens.light.typography.fontFamily,
          useMaterial3: true,
          extensions: const [Tokens.light],
        ),
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

    final style = button.style!;
    final bg = style.backgroundColor!.resolve({MaterialState.disabled});
    expect(bg, PandoraTokens.neutral300);

    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, isFalse);
  });
}
