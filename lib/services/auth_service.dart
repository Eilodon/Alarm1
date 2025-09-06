import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthService {
  final LocalAuthentication _auth;
  AuthService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  Future<bool> authenticate(AppLocalizations l10n) async {
    try {
      return await _auth.authenticate(
        localizedReason: l10n.authReason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException catch (e, st) {
      debugPrint(l10n.errorWithMessage('${e.message ?? e.toString()}\n$st'));
      return false;
    } catch (e, st) {
      // Catch any other unexpected errors and fail gracefully instead of
      // bubbling the exception up to the caller which could crash the app.
      debugPrint(l10n.errorWithMessage('${e.toString()}\n$st'));
      return false;
    }
  }
}
