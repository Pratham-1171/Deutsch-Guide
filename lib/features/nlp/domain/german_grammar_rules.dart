import 'german_lexicon.dart';
import 'german_nlp_engine.dart';

/// Metadata shared by the rule catalogue, tests and future learner UI.
class GermanRuleMetadata {
  const GermanRuleMetadata({
    required this.id,
    required this.level,
    required this.topic,
    required this.severity,
  });

  final String id;
  final String level;
  final String topic;
  final GrammarSeverity severity;
}

class GermanRuleRegistry {
  static const rules = <GermanRuleMetadata>[
    GermanRuleMetadata(
      id: 'DE-CAP-001', level: 'A1', topic: 'Sentence capitalization',
      severity: GrammarSeverity.warning,
    ),
    GermanRuleMetadata(
      id: 'DE-CAP-002', level: 'A1', topic: 'Noun capitalization',
      severity: GrammarSeverity.warning,
    ),
    GermanRuleMetadata(
      id: 'DE-VERB-001', level: 'A1', topic: 'Present-tense agreement',
      severity: GrammarSeverity.error,
    ),
    GermanRuleMetadata(
      id: 'DE-ARTICLE-001', level: 'A1', topic: 'Article and noun gender',
      severity: GrammarSeverity.warning,
    ),
    GermanRuleMetadata(
      id: 'DE-WORD-ORDER-001', level: 'A1', topic: 'Main-clause word order',
      severity: GrammarSeverity.warning,
    ),
  ];

  static GermanRuleMetadata? byId(String id) {
    for (final rule in rules) {
      if (rule.id == id) return rule;
    }
    return null;
  }
}

/// Conservative A1 checks. A rule only reports patterns represented in the
/// bundled lexicon; it does not attempt a complete syntactic parse.
class GermanGrammarRules {
  const GermanGrammarRules();

  static const _timeAdverbs = {
    'heute', 'morgen', 'gestern', 'jetzt', 'später',
    'oft', 'manchmal', 'normalerweise',
  };

  static const _presentForms = <String, Map<String, String>>{
    'sein': {
      'ich': 'bin', 'du': 'bist', 'er': 'ist', 'sie': 'ist',
      'es': 'ist', 'wir': 'sind', 'ihr': 'seid', 'Sie': 'sind',
    },
    'haben': {
      'ich': 'habe', 'du': 'hast', 'er': 'hat', 'sie': 'hat',
      'es': 'hat', 'wir': 'haben', 'ihr': 'habt', 'Sie': 'haben',
    },
    'lernen': {
      'ich': 'lerne', 'du': 'lernst', 'er': 'lernt', 'sie': 'lernt',
      'es': 'lernt', 'wir': 'lernen', 'ihr': 'lernt', 'Sie': 'lernen',
    },
    'wohnen': {
      'ich': 'wohne', 'du': 'wohnst', 'er': 'wohnt', 'sie': 'wohnt',
      'es': 'wohnt', 'wir': 'wohnen', 'ihr': 'wohnt', 'Sie': 'wohnen',
    },
    'kommen': {
      'ich': 'komme', 'du': 'kommst', 'er': 'kommt', 'sie': 'kommt',
      'es': 'kommt', 'wir': 'kommen', 'ihr': 'kommt', 'Sie': 'kommen',
    },
    'machen': {
      'ich': 'mache', 'du': 'machst', 'er': 'macht', 'sie': 'macht',
      'es': 'macht', 'wir': 'machen', 'ihr': 'macht', 'Sie': 'machen',
    },
    'gehen': {
      'ich': 'gehe', 'du': 'gehst', 'er': 'geht', 'sie': 'geht',
      'es': 'geht', 'wir': 'gehen', 'ihr': 'geht', 'Sie': 'gehen',
    },
    'sprechen': {
      'ich': 'spreche', 'du': 'sprichst', 'er': 'spricht', 'sie': 'spricht',
      'es': 'spricht', 'wir': 'sprechen', 'ihr': 'sprecht', 'Sie': 'sprechen',
    },
  };

  List<GrammarFinding> evaluate(List<GermanToken> tokens) {
    final findings = <GrammarFinding>[];
    _checkSentenceCapitalisation(tokens, findings);
    _checkKnownNounCapitalisation(tokens, findings);
    _checkPresentAgreement(tokens, findings);
    _checkArticleCompatibility(tokens, findings);
    _checkSimpleVerbSecondOrder(tokens, findings);
    return findings;
  }

  void _checkSentenceCapitalisation(
    List<GermanToken> tokens, List<GrammarFinding> findings,
  ) {
    if (tokens.isEmpty) return;
    final first = tokens.first;
    if (RegExp(r'^[a-zäöüß]').hasMatch(first.text)) {
      findings.add(GrammarFinding(
        ruleId: 'DE-CAP-001',
        message: 'Start the sentence with a capital letter.',
        explanation: 'In German, the first word of a sentence begins with a capital letter.',
        severity: GrammarSeverity.warning,
        start: first.start,
        length: first.text.length,
        suggestion: first.text[0].toUpperCase() + first.text.substring(1),
      ));
    }
  }

  void _checkKnownNounCapitalisation(
    List<GermanToken> tokens, List<GrammarFinding> findings,
  ) {
    for (final token in tokens) {
      final lower = token.text.toLowerCase();
      if (GermanLexicon.nounGenders.containsKey(lower) && token.text == lower) {
        findings.add(GrammarFinding(
          ruleId: 'DE-CAP-002',
          message: 'German nouns begin with a capital letter.',
          explanation: '"${token.text}" is a noun. Write it with an initial capital.',
          severity: GrammarSeverity.warning,
          start: token.start,
          length: token.text.length,
          suggestion: token.text[0].toUpperCase() + token.text.substring(1),
        ));
      }
    }
  }

  void _checkPresentAgreement(
    List<GermanToken> tokens, List<GrammarFinding> findings,
  ) {
    for (var i = 0; i + 1 < tokens.length; i++) {
      final subjectToken = tokens[i];
      final subjectText = subjectToken.text;
      final subject = subjectText == 'Sie' ? 'Sie' : subjectText.toLowerCase();
      if (!GermanLexicon.pronouns.contains(subject)) continue;
      final verb = tokens[i + 1];
      if (verb.partOfSpeech != GermanPartOfSpeech.verb) continue;
      final forms = _presentForms[verb.lemma];
      final expected = forms?[subject];
      if (expected == null || expected == verb.text.toLowerCase()) continue;
      findings.add(GrammarFinding(
        ruleId: 'DE-VERB-001',
        message: 'Check the verb form for "$subjectText".',
        explanation: 'The present-tense form of "${verb.lemma}" must agree with "$subjectText".',
        severity: GrammarSeverity.error,
        start: verb.start,
        length: verb.text.length,
        suggestion: expected,
      ));
    }
  }

  void _checkArticleCompatibility(
    List<GermanToken> tokens, List<GrammarFinding> findings,
  ) {
    // These sets list forms that can occur with each singular gender across
    // cases. This avoids the old false positives for "den Mann", "dem Mann",
    // "des Mannes", "der Frau" and "dem Kind". Case is not guessed.
    const validForms = <String, Set<String>>{
      'der': {'der', 'den', 'dem', 'des', 'ein', 'einen', 'einem', 'eines'},
      'die': {'die', 'der', 'eine', 'einer'},
      'das': {'das', 'dem', 'des', 'ein', 'einem', 'eines'},
    };
    for (var i = 0; i + 1 < tokens.length; i++) {
      final article = tokens[i];
      final noun = tokens[i + 1];
      final gender = GermanLexicon.nounGenders[noun.text.toLowerCase()];
      if (gender == null) continue;
      final form = article.text.toLowerCase();
      if (!GermanLexicon.articles.contains(form)) continue;
      if (validForms[gender]!.contains(form)) continue;
      findings.add(GrammarFinding(
        ruleId: 'DE-ARTICLE-001',
        message: 'Check the article for "${noun.text}".',
        explanation: 'The dictionary gender of "${noun.text}" is $gender. The article form "$form" is not used with this gender in the supported singular forms. The correct form depends on the case, so no automatic replacement is suggested.',
        severity: GrammarSeverity.warning,
        start: article.start,
        length: article.text.length,
      ));
    }
  }

  void _checkSimpleVerbSecondOrder(
    List<GermanToken> tokens, List<GrammarFinding> findings,
  ) {
    if (tokens.length < 3) return;
    final subject = tokens[0].text.toLowerCase();
    final adverb = tokens[1].text.toLowerCase();
    final verb = tokens[2];
    if (!GermanLexicon.pronouns.contains(subject) ||
        !_timeAdverbs.contains(adverb) ||
        verb.partOfSpeech != GermanPartOfSpeech.verb) return;
    findings.add(GrammarFinding(
      ruleId: 'DE-WORD-ORDER-001',
      message: 'In a simple main clause, the conjugated verb is usually in position two.',
      explanation: 'Move the conjugated verb directly after the subject: "${tokens[0].text} ${verb.text} $adverb".',
      severity: GrammarSeverity.warning,
      start: verb.start,
      length: verb.text.length,
      suggestion: '${tokens[0].text} ${verb.text} ${tokens[1].text}',
    ));
  }
}
