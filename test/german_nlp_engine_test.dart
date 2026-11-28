import 'package:deutsch_guide/features/nlp/domain/german_grammar_rules.dart';
import 'package:deutsch_guide/features/nlp/domain/german_nlp_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = GermanNlpEngine();

  group('Offline German NLP', () {
    test('tokenizes and identifies a known verb', () {
      final result = engine.analyze('Ich lerne Deutsch.');
      expect(
        result.tokens.map((token) => token.text),
        ['Ich', 'lerne', 'Deutsch', '.'],
      );
      expect(result.tokens[1].lemma, 'lernen');
      expect(result.tokens[1].partOfSpeech, GermanPartOfSpeech.verb);
    });

    test('reports sentence-initial capitalization', () {
      final result = engine.analyze('ich lerne Deutsch.');
      expect(result.findings.any((f) => f.ruleId == 'DE-CAP-001'), isTrue);
    });

    test('reports capitalization of a known German noun', () {
      final result = engine.analyze('Ich lese ein buch.');
      expect(result.findings.any((f) => f.ruleId == 'DE-CAP-002'), isTrue);
    });

    test('detects sein, haben and regular present-tense agreement', () {
      final cases = {
        'Ich bist müde.': 'bin',
        'Du habe ein Buch.': 'hast',
        'Du lernen Deutsch.': 'lernst',
        'Er wohnen in Berlin.': 'wohnt',
        'Wir sprecht Deutsch.': 'sprechen',
      };
      for (final entry in cases.entries) {
        final finding = engine.analyze(entry.key).findings.firstWhere(
              (f) => f.ruleId == 'DE-VERB-001',
            );
        expect(finding.suggestion, entry.value, reason: entry.key);
      }
    });

    test('accepts singular and plural readings of lowercase sie', () {
      for (final sentence in [
        'sie spricht Deutsch.',
        'sie sprechen Deutsch.',
      ]) {
        final result = engine.analyze(sentence);
        expect(
          result.findings.any((f) => f.ruleId == 'DE-VERB-001'),
          isFalse,
          reason: sentence,
        );
      }
    });

    test('does not flag valid masculine article forms across cases', () {
      for (final sentence in [
        'der Mann',
        'den Mann',
        'dem Mann',
        'des Mannes',
        'ein Mann',
        'einen Mann',
        'einem Mann',
        'eines Mannes',
      ]) {
        final result = engine.analyze(sentence);
        expect(
          result.findings.any((f) => f.ruleId == 'DE-ARTICLE-001'),
          isFalse,
          reason: sentence,
        );
      }
    });

    test('does not flag valid feminine and neuter forms', () {
      for (final sentence in [
        'die Frau',
        'der Frau',
        'eine Frau',
        'einer Frau',
        'das Kind',
        'dem Kind',
        'des Kindes',
        'ein Kind',
      ]) {
        final result = engine.analyze(sentence);
        expect(
          result.findings.any((f) => f.ruleId == 'DE-ARTICLE-001'),
          isFalse,
          reason: sentence,
        );
      }
    });

    test('article mismatch does not guess a case-specific replacement', () {
      final result = engine.analyze('das Mann');
      final finding = result.findings.firstWhere(
        (f) => f.ruleId == 'DE-ARTICLE-001',
      );
      expect(finding.suggestion, isNull);
    });

    test('detects a simple subject-adverb-verb order issue', () {
      final result = engine.analyze('Ich morgen gehe.');
      expect(
        result.findings.any((f) => f.ruleId == 'DE-WORD-ORDER-001'),
        isTrue,
      );
    });

    test('registry exposes stable A1 rule metadata', () {
      expect(GermanRuleRegistry.byId('DE-VERB-001')?.level, 'A1');
      expect(
        GermanRuleRegistry.byId('DE-VERB-001')?.topic,
        'Present-tense agreement',
      );
    });

    test('does not invent findings for empty input', () {
      final result = engine.analyze('   ');
      expect(result.tokens, isEmpty);
      expect(result.findings, isEmpty);
    });

    test('returns stable character offsets', () {
      const sentence = 'Ich bist müde.';
      final result = engine.analyze(sentence);
      final verb = result.tokens.firstWhere((token) => token.text == 'bist');
      expect(sentence.substring(verb.start, verb.end), 'bist');
    });
  });
}
