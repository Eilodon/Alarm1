import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

class CalendarService {
  CalendarService._();
  static final CalendarService instance = CalendarService._();

  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _signIn => _googleSignIn ??=
      GoogleSignIn(scopes: <String>[calendar.CalendarApi.calendarScope]);

  Future<calendar.CalendarApi?> _getApi() async {
    var account = await _signIn.signInSilently();
    account ??= await _signIn.signIn();
    if (account == null) return null;
    final headers = await account.authHeaders;
    final client = _AuthClient(headers);
    return calendar.CalendarApi(client);
  }

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
    final created = await api.events.insert(event, 'primary');
    return created.id;
  }

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
    await api.events.patch(event, 'primary', eventId);
  }

  Future<void> deleteEvent(String eventId) async {
    final api = await _getApi();
    if (api == null) return;
    await api.events.delete('primary', eventId);
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
