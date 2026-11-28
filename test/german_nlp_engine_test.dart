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
      expect(
          result.findings.any((f) => f.ruleId == 'DE-WORD-ORDER-001'), isTrue);
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
Formatted 3 files (3 changed) in 0.01 seconds.
##[group]Run flutter analyze
[36;1mflutter analyze[0m
shell: /usr/bin/bash -e {0}
env:
  FLUTTER_ROOT: /opt/hostedtoolcache/flutter/stable-3.50.1-x64/flutter
  PUB_CACHE: /home/runner/.pub-cache
##[endgroup]
Resolving dependencies...
Downloading packages...
  flutter_lints 5.0.0 (6.0.0 available)
  flutter_riverpod 2.6.1 (3.5.0 available)
  go_router 14.8.1 (18.1.4 available)
  lints 5.1.1 (6.1.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  riverpod 2.6.1 (3.5.0 available)
  test_api 0.7.14 (0.7.15 available)
  vector_math 2.4.3 (2.4.4 available)
Got dependencies!
8 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing Deutsch-Guide...                                      

   info • Statements in an if should be enclosed in a block. Try wrapping the statement in a block • lib/features/nlp/domain/german_nlp_engine.dart:365:60 • curly_braces_in_flow_control_structures

1 issue found. (ran in 7.2s)
##[error]Process completed with exit code 1.
Post job cleanup.
##[start-action display=Cache pub dependencies;id=__e0748a8d-d16d-414b-ab87-c03e61c82a0b.cache-pub]
