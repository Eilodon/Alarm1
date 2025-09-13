import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:pandora/features/note/data/calendar_service.dart';

class FakeSignInSuccess extends GoogleSignInPlatform {
  @override
  Future<void> init(InitParameters params) async {}

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
      AttemptLightweightAuthenticationParameters params) async {
    return AuthenticationResults(
      user: const GoogleSignInUserData(
        email: 'e',
        id: '1',
        displayName: 'd',
      ),
      authenticationTokens: const AuthenticationTokenData(
        accessToken: 'token',
        idToken: 'id',
      ),
    );
  }

  @override
  Future<AuthenticationResults> authenticate(
      AuthenticateParameters params) async {
    return AuthenticationResults(
      user: const GoogleSignInUserData(
        email: 'e',
        id: '1',
        displayName: 'd',
      ),
      authenticationTokens: const AuthenticationTokenData(
        accessToken: 'token',
        idToken: 'id',
      ),
    );
  }

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
      ClientAuthorizationTokensForScopesParameters params) async {
    return const ClientAuthorizationTokenData(accessToken: 'token');
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
      ServerAuthorizationTokensForScopesParameters params) async {
    return null;
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<void> signOut(SignOutParams params) async {}

  @override
  Future<void> disconnect(DisconnectParams params) async {}

  @override
  Stream<AuthenticationEvent>? get authenticationEvents =>
      const Stream<AuthenticationEvent>.empty();
}

class FakeSignInFail extends GoogleSignInPlatform {
  @override
  Future<void> init(InitParameters params) async {}

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
      AttemptLightweightAuthenticationParameters params) async {
    return null;
  }

  @override
  Future<AuthenticationResults> authenticate(
      AuthenticateParameters params) async {
    throw const GoogleSignInException(
      code: GoogleSignInExceptionCode.canceled,
    );
  }

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
      ClientAuthorizationTokensForScopesParameters params) async {
    return null;
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
      ServerAuthorizationTokensForScopesParameters params) async {
    return null;
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<void> signOut(SignOutParams params) async {}

  @override
  Future<void> disconnect(DisconnectParams params) async {}

  @override
  Stream<AuthenticationEvent>? get authenticationEvents =>
      const Stream<AuthenticationEvent>.empty();
}

class FakeHttpClient extends HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FakeHttpClientRequest(method, url);
  }

  @override
  void close({bool force = false}) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientRequest implements HttpClientRequest {
  final String method;
  final Uri url;
  @override
  final HttpHeaders headers = HttpHeaders();
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  int contentLength = 0;

  FakeHttpClientRequest(this.method, this.url);

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    if (method == 'POST') {
      return FakeHttpClientResponse(200, '{"id":"fake-id"}');
    } else {
      return FakeHttpClientResponse(200, '');
    }
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final int _statusCode;
  final List<int> _body;
  FakeHttpClientResponse(this._statusCode, String body)
      : _body = utf8.encode(body);

  @override
  int get statusCode => _statusCode;
  @override
  int get contentLength => _body.length;
  @override
  bool get isRedirect => false;
  @override
  bool get persistentConnection => false;
  @override
  String get reasonPhrase => '';
  @override
  HttpHeaders get headers => HttpHeaders();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_body]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('createEvent returns event id on success', () async {
    final previous = GoogleSignInPlatform.instance;
    GoogleSignInPlatform.instance = FakeSignInSuccess();
    final id = await HttpOverrides.runZoned(() async {
      return await CalendarServiceImpl.instance.createEvent(
        title: 't',
        description: 'd',
        start: DateTime(2024, 1, 1),
      );
    }, createHttpClient: (context) => FakeHttpClient());
    expect(id, 'fake-id');
    GoogleSignInPlatform.instance = previous;
  });

  test('createEvent returns null when sign in fails', () async {
    final previous = GoogleSignInPlatform.instance;
    GoogleSignInPlatform.instance = FakeSignInFail();
    final id = await CalendarServiceImpl.instance.createEvent(
      title: 't',
      description: 'd',
      start: DateTime(2024, 1, 1),
    );
    expect(id, isNull);
    GoogleSignInPlatform.instance = previous;
  });
}
