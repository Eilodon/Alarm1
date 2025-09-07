import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alarm_domain/alarm_domain.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('SaveNotes', () {
    late NoteRepository repository;
    late SaveNotes usecase;
    final notes = [
      const Note(id: '1', title: 't1', content: 'c1'),
      const Note(id: '2', title: 't2', content: 'c2'),
    ];

    setUp(() {
      repository = _MockNoteRepository();
      usecase = SaveNotes(repository);
    });

    test('saves notes using repository', () async {
      when(() => repository.saveNotes(notes)).thenAnswer((_) async {});

      await usecase(notes);

      verify(() => repository.saveNotes(notes)).called(1);
    });

    test('propagates repository errors', () {
      when(() => repository.saveNotes(notes))
          .thenThrow(Exception('encryption error'));

      expect(usecase(notes), throwsA(isA<Exception>()));
    });
  });
}
