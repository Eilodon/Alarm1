import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes_reminder_app/generated/app_localizations.dart';
import 'package:logger/logger.dart';

class AuthService {
  final LocalAuthentication _auth;
  final Logger _logger;

  AuthService({LocalAuthentication? auth, Logger? logger})
      : _auth = auth ?? LocalAuthentication(),
        _logger = logger ?? Logger();

  Future<bool> authenticate(AppLocalizations l10n) async {
    try {
      return await _auth.authenticate(
        localizedReason: l10n.authReason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException catch (e, st) {
      _logger.e(
        l10n.errorWithMessage(e.message ?? e.toString()),
        error: e,
        stackTrace: st,
      );
      return false;
    } catch (e, st) {
      // Catch any other unexpected errors and fail gracefully instead of
      // bubbling the exception up to the caller which could crash the app.
      _logger.e(
        l10n.errorWithMessage(e.toString()),
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}
