import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandora/widgets/tag_selector.dart';
import 'package:pandora/theme/tokens.dart';

void main() {
  testWidgets('TagSelector uses themed colors in light and dark', (
    WidgetTester tester,
  ) async {
    Future<void> pumpTheme(ThemeData theme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: TagSelector(
            availableTags: const [],
            selectedTags: const [],
            onChanged: (_) {},
            selectedColor: 0,
            onColorChanged: (_) {},
          ),
        ),
      );
    }

    await pumpTheme(ThemeData(extensions: const [Tokens.light]));
    var context = tester.element(find.byType(TagSelector));
    var tokens = Theme.of(context).extension<Tokens>()!;
    var scheme = Theme.of(context).colorScheme;
    var chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();

    expect(chips.length, 8);
    expect(chips[0].selectedColor, scheme.background);
    expect(chips[1].selectedColor, tokens.colors.primary);
    expect(chips[2].selectedColor, tokens.colors.secondary);
    expect(chips[3].selectedColor, tokens.colors.error);
    expect(chips[4].selectedColor, tokens.colors.warning);
    expect(chips[5].selectedColor, tokens.colors.info);
    expect(chips[6].selectedColor, tokens.colors.neutral700);
    expect(chips[7].selectedColor, tokens.colors.neutral900);

    await pumpTheme(
      ThemeData(brightness: Brightness.dark, extensions: const [Tokens.dark]),
    );
    context = tester.element(find.byType(TagSelector));
    tokens = Theme.of(context).extension<Tokens>()!;
    scheme = Theme.of(context).colorScheme;
    chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();

    expect(chips[0].selectedColor, scheme.background);
    expect(chips[1].selectedColor, tokens.colors.primary);
    expect(chips[2].selectedColor, tokens.colors.secondary);
    expect(chips[3].selectedColor, tokens.colors.error);
    expect(chips[4].selectedColor, tokens.colors.warning);
    expect(chips[5].selectedColor, tokens.colors.info);
    expect(chips[6].selectedColor, tokens.colors.neutral700);
    expect(chips[7].selectedColor, tokens.colors.neutral900);
  });
}
