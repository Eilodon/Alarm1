import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes_reminder_app/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MockLocalAuth extends Mock implements LocalAuthentication {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuth mock;
  late AuthService service;
  late AppLocalizations l10n;

  setUp(() async {
    mock = MockLocalAuth();
    service = AuthService(auth: mock);
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('authenticate returns true on success', () async {
    when(() => mock.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => true);

    final ok = await service.authenticate(l10n);
    expect(ok, isTrue);
  });

  test('authenticate returns false on failure', () async {
    when(() => mock.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )).thenThrow(Exception('fail'));

    final ok = await service.authenticate(l10n);
    expect(ok, isFalse);
  });
}
