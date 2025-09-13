import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:pandora/services/connectivity_service.dart';

class FakeConnectivity extends ConnectivityPlatform {
  final _controller = StreamController<List<ConnectivityResult>>();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return [ConnectivityResult.wifi];
  }

  void emit(ConnectivityResult result) {
    _controller.add([result]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final original = ConnectivityPlatform.instance;
  addTearDown(() => ConnectivityPlatform.instance = original);

  testWidgets('shows SnackBar when connection lost', (tester) async {
    final fake = FakeConnectivity();
    ConnectivityPlatform.instance = fake;

    final messengerKey = GlobalKey<ScaffoldMessengerState>();

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      scaffoldMessengerKey: messengerKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          ConnectivityService().initialize(l10n, messengerKey);
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    fake.emit(ConnectivityResult.none);
    await tester.pump();

    expect(find.text(l10n.noInternetConnection), findsOneWidget);
  });

  testWidgets('shows SnackBar when connection restored', (tester) async {
    final fake = FakeConnectivity();
    ConnectivityPlatform.instance = fake;

    final messengerKey = GlobalKey<ScaffoldMessengerState>();

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      scaffoldMessengerKey: messengerKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          ConnectivityService().initialize(l10n, messengerKey);
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    fake.emit(ConnectivityResult.none);
    await tester.pump();

    messengerKey.currentState!.clearSnackBars();

    fake.emit(ConnectivityResult.wifi);
    await tester.pump();

    expect(find.text(l10n.internetConnectionRestored), findsOneWidget);
  });
}
