import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pandora/services/auth_service.dart';
import 'package:pandora/generated/app_localizations.dart';
import 'package:logger/logger.dart';

class MockLocalAuth extends Mock implements LocalAuthentication {}
class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuth mock;
  late AuthService service;
  late MockLogger logger;
  late AppLocalizations l10n;

  setUp(() async {
    mock = MockLocalAuth();
    logger = MockLogger();
    service = AuthService(auth: mock, logger: logger);
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

  test('authenticate returns false on PlatformException', () async {
    when(() => mock.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )).thenThrow(const PlatformException(code: 'fail'));

    final ok = await service.authenticate(l10n);
    expect(ok, isFalse);
    verify(() => logger.e(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).called(1);
  });

  test('authenticate returns false on generic exception', () async {
    when(() => mock.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )).thenThrow(Exception('fail'));

    final ok = await service.authenticate(l10n);
    expect(ok, isFalse);
    verify(() => logger.e(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).called(1);
  });
}
