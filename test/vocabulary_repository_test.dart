import 'package:deutsch_guide/features/vocabulary/data/vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('A1 vocabulary catalog', () {
    test('loads the bundled offline noun catalog', () async {
      const repository = VocabularyRepository();
      final catalog = await repository.loadLevel('A1');

      expect(catalog.level, 'A1');
      expect(catalog.schemaVersion, 1);
      expect(catalog.entries, isNotEmpty);
      expect(catalog.entries.length, greaterThanOrEqualTo(50));
    });

    test('every noun has an article, meaning, topic and bilingual example',
        () async {
      const repository = VocabularyRepository();
      final catalog = await repository.loadLevel('A1');

      for (final entry in catalog.entries) {
        expect(entry.id, isNotEmpty);
        expect(entry.lemma, isNotEmpty);
        expect(entry.meaningEn, isNotEmpty, reason: entry.id);
        expect(entry.topicId, isNotEmpty, reason: entry.id);
        expect(entry.exampleDe, isNotEmpty, reason: entry.id);
        expect(entry.exampleEn, isNotEmpty, reason: entry.id);
        expect(entry.level, 'A1', reason: entry.id);
      }
    });

    test('rejects duplicate IDs and duplicate lemmas', () {
      final entry = {
        'id': 'noun.test',
        'lemma': 'Haus',
        'article': 'das',
        'plural': 'Häuser',
        'meaningEn': 'house',
        'topicId': 'home',
        'exampleDe': 'Das Haus ist groß.',
        'exampleEn': 'The house is large.',
        'level': 'A1',
      };
      expect(
        () => VocabularyCatalog.fromJson({
          'contentVersion': 1,
          'schemaVersion': 1,
          'level': 'A1',
          'entries': [entry, {...entry, 'id': 'noun.test2'}],
        }),
        throwsFormatException,
      );
    });

    test('rejects an invalid noun article', () {
      expect(
        () => VocabularyEntry.fromJson({
          'id': 'noun.invalid',
          'lemma': 'Haus',
          'article': 'den',
          'plural': 'Häuser',
          'meaningEn': 'house',
          'topicId': 'home',
          'exampleDe': 'Das Haus ist groß.',
          'exampleEn': 'The house is large.',
          'level': 'A1',
        }),
        throwsFormatException,
      );
    });

    test('does not pretend later-level vocabulary is bundled', () async {
      const repository = VocabularyRepository();
      await expectLater(repository.loadLevel('A2'), throwsUnsupportedError);
    });
  });
}
