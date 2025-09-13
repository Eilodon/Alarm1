import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:alarm_domain/alarm_domain.dart';
import 'package:pandora/pandora_ui/teach_ai_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TeachAiModal returns input and triggers haptic', (tester) async {
    int hapticCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method.startsWith('HapticFeedback')) {
            hapticCalls++;
          }
          return null;
        });

    String? result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => const TeachAiModal(),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'foo');
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.send));
    await tester.pumpAndSettle();

    expect(result, 'foo');
    expect(hapticCalls, greaterThan(0));

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
}
