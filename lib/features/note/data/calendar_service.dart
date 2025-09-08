import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:notes_reminder_app/features/note/domain/domain.dart';

class CalendarServiceImpl implements CalendarService {
  CalendarServiceImpl._();
  static final CalendarServiceImpl instance = CalendarServiceImpl._();


  final _signIn = GoogleSignIn.instance;


  bool _initialized = false;

  Future<calendar.CalendarApi?> _getApi() async {
    try {
      if (!_initialized) {
        await _signIn.initialize();
        _initialized = true;
      }
      GoogleSignInAccount? account;
      final silentSignIn = _signIn.attemptLightweightAuthentication();
      if (silentSignIn != null) {
        account = await silentSignIn;
      }
      account ??= await _signIn.authenticate(
        scopeHint: <String>[calendar.CalendarApi.calendarScope],
      );
      if (account == null) return null;
      final headers = await account.authorizationClient.authorizationHeaders(
        <String>[calendar.CalendarApi.calendarScope],
        promptIfNecessary: true,
      );
      if (headers == null) return null;
      final client = _AuthClient(headers);
      return calendar.CalendarApi(client);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> createEvent({
    required String title,
    required String description,
    required DateTime start,
    DateTime? end,
  }) async {
    final api = await _getApi();
    if (api == null) return null;
    final event = calendar.Event(
      summary: title,
      description: description,
      start: calendar.EventDateTime(dateTime: start),
      end: calendar.EventDateTime(
        dateTime: end ?? start.add(const Duration(hours: 1)),
      ),
    );
    try {
      final created = await api.events.insert(event, 'primary');
      return created.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateEvent(
    String eventId, {
    required String title,
    required String description,
    required DateTime start,
    DateTime? end,
  }) async {
    final api = await _getApi();
    if (api == null) return;
    final event = calendar.Event(
      summary: title,
      description: description,
      start: calendar.EventDateTime(dateTime: start),
      end: calendar.EventDateTime(
        dateTime: end ?? start.add(const Duration(hours: 1)),
      ),
    );
    try {
      await api.events.patch(event, 'primary', eventId);
    } catch (e) {
      return;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final api = await _getApi();
    if (api == null) return;
    try {
      await api.events.delete('primary', eventId);
    } catch (e) {
      return;
    }
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
