import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth;
  AuthService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
