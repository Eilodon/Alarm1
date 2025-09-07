import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_reminder_app/features/note/note.dart';
import 'package:notes_reminder_app/features/backup/data/note_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DummyRepo extends Fake implements NoteRepository {}

class FakeConnectivity extends Connectivity {
  @override
  Stream<ConnectivityResult> get onConnectivityChanged => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('syncNote marks unsynced when offline', () async {
    SharedPreferences.setMockInitialValues({});
    final service = NoteSyncServiceImpl(
      repository: DummyRepo(),
      connectivity: FakeConnectivity(),
    );
    await service.init((_) => null);
    await service.syncNote(const Note(
      id: '1',
      title: 't',
      content: 'c',
      summary: '',
      actionItems: [],
      dates: [],
    ));
    expect(service.unsyncedNoteIds.contains('1'), isTrue);
  });
}
