import 'package:flutter_test/flutter_test.dart';
import 'package:pandora/features/note/note.dart';
import 'package:pandora/features/backup/data/note_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DummyRepo extends Fake implements NoteRepository {}

class DummyFirestore extends Fake implements FirebaseFirestore {}
class DummyAuth extends Fake implements FirebaseAuth {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('syncNote marks unsynced when offline', () async {
    SharedPreferences.setMockInitialValues({});
    final service = NoteSyncServiceImpl(
      repository: DummyRepo(),
      firestore: DummyFirestore(),
      auth: DummyAuth(),
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
