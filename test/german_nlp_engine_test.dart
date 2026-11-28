import 'package:deutsch_guide/features/nlp/domain/german_nlp_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = GermanNlpEngine();

  group('Offline German NLP', () {
    test('tokenizes and identifies known verbs and nouns', () {
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

    test('detects common sein agreement errors', () {
      final result = engine.analyze('Ich bist müde.');
      final finding = result.findings.firstWhere(
        (f) => f.ruleId == 'DE-VERB-001',
      );
      expect(finding.suggestion, 'bin');
    });

    test('detects common haben agreement errors', () {
      final result = engine.analyze('Du habe ein Buch.');
      final finding = result.findings.firstWhere(
        (f) => f.ruleId == 'DE-VERB-001',
      );
      expect(finding.suggestion, 'hast');
    });

    test('flags a known noun article gender mismatch cautiously', () {
      final result = engine.analyze('das Mann');
      expect(result.findings.any((f) => f.ruleId == 'DE-ARTICLE-001'), isTrue);
    });

    test('detects a simple subject-adverb-verb order issue', () {
      final result = engine.analyze('Ich morgen gehe.');
      expect(result.findings.any((f) => f.ruleId == 'DE-WORD-ORDER-001'), isTrue);
    });

    test('does not invent findings for empty input', () {
      final result = engine.analyze('   ');
      expect(result.tokens, isEmpty);
      expect(result.findings, isEmpty);
    });

    test('returns stable character offsets', () {
      final result = engine.analyze('Ich bist müde.');
      final verb = result.tokens.firstWhere((token) => token.text == 'bist');
      expect('Ich bist müde.'.substring(verb.start, verb.end), 'bist');
    });
  });
}
