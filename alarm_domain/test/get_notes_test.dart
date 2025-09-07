import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alarm_domain/alarm_domain.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('GetNotes', () {
    late NoteRepository repository;
    late GetNotes usecase;

    setUp(() {
      repository = _MockNoteRepository();
      usecase = GetNotes(repository);
    });

    final notes = [
      const Note(id: '1', title: 't1', content: 'c1'),
      const Note(id: '2', title: 't2', content: 'c2'),
    ];

    test('returns notes from repository', () async {
      when(() => repository.getNotes(onDecryptFailure: any(named: 'onDecryptFailure')))
          .thenAnswer((_) async => notes);

      final result = await usecase();

      expect(result, notes);
      verify(() => repository.getNotes(onDecryptFailure: any(named: 'onDecryptFailure')))
          .called(1);
    });

    test('propagates repository errors', () {
      when(() => repository.getNotes(onDecryptFailure: any(named: 'onDecryptFailure')))
          .thenThrow(Exception('decryption error'));

      expect(usecase(), throwsA(isA<Exception>()));
    });

    test('invokes onDecryptFailure callback when provided', () async {
      when(() => repository.getNotes(onDecryptFailure: any(named: 'onDecryptFailure')))
          .thenAnswer((invocation) async {
        final cb = invocation.namedArguments[#onDecryptFailure] as void Function(String)?;
        cb?.call('bad-id');
        return [];
      });

      var capturedId = '';
      await usecase(onDecryptFailure: (id) => capturedId = id);

      expect(capturedId, 'bad-id');
    });
  });
}
