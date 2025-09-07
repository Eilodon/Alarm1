import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alarm_domain/alarm_domain.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('UpdateNote', () {
    late NoteRepository repository;
    late UpdateNote usecase;
    const note = Note(id: '1', title: 't1', content: 'c1');

    setUp(() {
      repository = _MockNoteRepository();
      usecase = UpdateNote(repository);
    });

    test('updates note via repository', () async {
      when(() => repository.updateNote(note)).thenAnswer((_) async {});

      await usecase(note);

      verify(() => repository.updateNote(note)).called(1);
    });

    test('propagates repository errors', () {
      when(() => repository.updateNote(note))
          .thenThrow(Exception('encryption error'));

      expect(usecase(note), throwsA(isA<Exception>()));
    });
  });
}
