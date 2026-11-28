import 'german_grammar_rules.dart';
import 'german_lexicon.dart';
import 'german_nlp_models.dart';
import 'german_tokenizer.dart';

export 'german_nlp_models.dart';

/// Offline-first A1 rule engine. Its small, reviewed lexicon deliberately
/// limits coverage; an empty result never certifies a sentence as correct.
class GermanNlpEngine {
  const GermanNlpEngine();

  static const engineVersion = 'dart-rules-0.2.0';

  static const _lexicon = GermanLexicon();
  static const _tokenizer = GermanTokenizer();
  static const _rules = GermanGrammarRules();

  GermanAnalysis analyze(String text) {
    final tokens = _tokenizer.tokenize(text, _lexicon);
    final findings = _rules.evaluate(tokens);
    return GermanAnalysis(
      tokens: List.unmodifiable(tokens),
      findings: List.unmodifiable(findings),
      engineVersion: engineVersion,
    );
  }
}
