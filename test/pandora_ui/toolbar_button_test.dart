import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

import 'package:pandora/pandora_ui/toolbar_button.dart';
import 'package:pandora/theme/tokens.dart';

void main() {
  testWidgets('ToolbarButton has minimum size', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [Tokens.light]),
        home: Scaffold(
          body: ToolbarButton(
            icon: const Icon(Icons.add),
            label: 'Add',
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ToolbarButton), findsOneWidget);
    final size = tester.getSize(find.byType(ToolbarButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('ToolbarButton triggers haptic feedback on tap', (
    WidgetTester tester,
  ) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        calls.add(methodCall.method);
        return null;
      },
    );

    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [Tokens.light]),
        home: Scaffold(
          body: ToolbarButton(
            icon: const Icon(Icons.add),
            label: 'Add',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ToolbarButton), findsOneWidget);

    await tester.tap(find.byType(ToolbarButton));
    expect(pressed, isTrue);
    expect(calls, contains('HapticFeedback.vibrate'));

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  testWidgets('ToolbarButton shows tooltip and disabled state prevents taps',
      (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [Tokens.light]),
        home: Scaffold(
          body: ToolbarButton(
            icon: const Icon(Icons.add),
            label: 'Add',
            onPressed: () {
              pressed = true;
            },
            state: 'disabled',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byTooltip('Add'), findsOneWidget);

    await tester.tap(find.byType(ToolbarButton));
    expect(pressed, isFalse);

    final semantics = tester.getSemantics(find.byType(ToolbarButton));
    expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
  });
}
