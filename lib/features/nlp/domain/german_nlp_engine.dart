import 'package:flutter/foundation.dart';

enum GermanPartOfSpeech {
  pronoun,
  article,
  verb,
  noun,
  adjective,
  preposition,
  conjunction,
  punctuation,
  number,
  unknown,
}

enum GrammarSeverity { error, warning }

@immutable
class GermanToken {
  const GermanToken({
    required this.text,
    required this.lemma,
    required this.partOfSpeech,
    required this.start,
    required this.end,
  });

  final String text;
  final String lemma;
  final GermanPartOfSpeech partOfSpeech;
  final int start;
  final int end;
}

@immutable
class GrammarFinding {
  const GrammarFinding({
    required this.ruleId,
    required this.message,
    required this.explanation,
    required this.severity,
    required this.start,
    required this.length,
    this.suggestion,
  });

  final String ruleId;
  final String message;
  final String explanation;
  final GrammarSeverity severity;
  final int start;
  final int length;
  final String? suggestion;
}

@immutable
class GermanAnalysis {
  const GermanAnalysis({
    required this.tokens,
    required this.findings,
    required this.engineVersion,
  });

  final List<GermanToken> tokens;
  final List<GrammarFinding> findings;
  final String engineVersion;
}

/// Deterministic, fully offline German analysis for the A1–B1 learning path.
///
/// This is a curriculum-aware starter engine, not a replacement for a
/// statistical parser or a complete German grammar checker. Its small
/// lexicons intentionally limit rules to cases where the engine has evidence.
class GermanNlpEngine {
  const GermanNlpEngine();

  static const engineVersion = 'dart-rules-0.1.0';

  static final _tokenPattern = RegExp(
    r'[A-Za-zÄÖÜäöüß]+|[0-9]+|[^\s]',
    unicode: true,
  );

  static const _pronouns = {
    'ich',
    'du',
    'er',
    'sie',
    'es',
    'wir',
    'ihr',
    'Sie',
  };
  static const _articles = {
    'der',
    'die',
    'das',
    'den',
    'dem',
    'des',
    'ein',
    'eine',
    'einen',
    'einem',
    'einer',
    'eines',
  };
  static const _prepositions = {
    'an',
    'auf',
    'aus',
    'bei',
    'bis',
    'durch',
    'für',
    'gegen',
    'mit',
    'nach',
    'seit',
    'von',
    'zu',
    'in',
    'im',
    'ins',
    'über',
    'unter',
    'vor',
    'hinter',
    'neben',
    'zwischen',
  };
  static const _conjunctions = {
    'und',
    'oder',
    'aber',
    'denn',
    'weil',
    'dass',
    'wenn',
    'obwohl',
  };
  static const _knownNouns = {
    'mann',
    'frau',
    'kind',
    'hund',
    'katze',
    'haus',
    'buch',
    'schule',
    'universität',
    'stadt',
    'land',
    'freund',
    'freundin',
    'arbeit',
    'wasser',
    'kaffee',
    'tee',
    'apfel',
    'zug',
    'auto',
    'zimmer',
    'sprache',
    'frage',
    'antwort',
    'zeit',
    'tag',
    'morgen',
    'abend',
    'name',
    'familie',
    'mutter',
    'vater',
    'bruder',
    'schwester',
  };
  static const _nounGenders = {
    'mann': 'der',
    'hund': 'der',
    'kaffee': 'der',
    'tee': 'der',
    'apfel': 'der',
    'zug': 'der',
    'morgen': 'der',
    'abend': 'der',
    'tag': 'der',
    'name': 'der',
    'freund': 'der',
    'frau': 'die',
    'katze': 'die',
    'schule': 'die',
    'universität': 'die',
    'stadt': 'die',
    'arbeit': 'die',
    'sprache': 'die',
    'frage': 'die',
    'antwort': 'die',
    'zeit': 'die',
    'familie': 'die',
    'mutter': 'die',
    'schwester': 'die',
    'freundin': 'die',
    'buch': 'das',
    'kind': 'das',
    'haus': 'das',
    'land': 'das',
    'wasser': 'das',
    'auto': 'das',
    'zimmer': 'das',
  };
  static const _verbLemmas = {
    'bin': 'sein',
    'bist': 'sein',
    'ist': 'sein',
    'sind': 'sein',
    'seid': 'sein',
    'war': 'sein',
    'waren': 'sein',
    'habe': 'haben',
    'hast': 'haben',
    'hat': 'haben',
    'haben': 'haben',
    'habt': 'haben',
    'komme': 'kommen',
    'kommst': 'kommen',
    'kommt': 'kommen',
    'kommen': 'kommen',
    'wohne': 'wohnen',
    'wohnst': 'wohnen',
    'wohnt': 'wohnen',
    'wohnen': 'wohnen',
    'lerne': 'lernen',
    'lernst': 'lernen',
    'lernt': 'lernen',
    'lernen': 'lernen',
    'spreche': 'sprechen',
    'sprichst': 'sprechen',
    'spricht': 'sprechen',
    'sprechen': 'sprechen',
    'gehe': 'gehen',
    'gehst': 'gehen',
    'geht': 'gehen',
    'gehen': 'gehen',
    'mache': 'machen',
    'machst': 'machen',
    'macht': 'machen',
    'machen': 'machen',
  };
  static const _timeAdverbs = {
    'heute',
    'morgen',
    'gestern',
    'jetzt',
    'später',
    'oft',
    'manchmal',
    'normalerweise',
  };

  GermanAnalysis analyze(String text) {
    final matches = _tokenPattern.allMatches(text);
    final tokens = matches.map((match) {
      final value = match.group(0)!;
      final lower = value.toLowerCase();
      return GermanToken(
        text: value,
        lemma: _verbLemmas[lower] ?? lower,
        partOfSpeech: _classify(value),
        start: match.start,
        end: match.end,
      );
    }).toList(growable: false);

    final findings = <GrammarFinding>[];
    _checkSentenceCapitalisation(tokens, findings);
    _checkKnownNounCapitalisation(tokens, findings);
    _checkKnownVerbAgreement(tokens, findings);
    _checkKnownArticleGender(tokens, findings);
    _checkSimpleVerbSecondOrder(tokens, findings);

    return GermanAnalysis(
      tokens: List.unmodifiable(tokens),
      findings: List.unmodifiable(findings),
      engineVersion: engineVersion,
    );
  }

  GermanPartOfSpeech _classify(String value) {
    final lower = value.toLowerCase();
    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return GermanPartOfSpeech.number;
    }
    if (RegExp(r'^[^A-Za-zÄÖÜäöüß0-9]$', unicode: true).hasMatch(value)) {
      return GermanPartOfSpeech.punctuation;
    }
    if (_pronouns.contains(value) || _pronouns.contains(lower)) {
      return GermanPartOfSpeech.pronoun;
    }
    if (_articles.contains(lower)) return GermanPartOfSpeech.article;
    if (_verbLemmas.containsKey(lower)) return GermanPartOfSpeech.verb;
    if (_prepositions.contains(lower)) return GermanPartOfSpeech.preposition;
    if (_conjunctions.contains(lower)) return GermanPartOfSpeech.conjunction;
    if (_knownNouns.contains(lower)) return GermanPartOfSpeech.noun;
    if (lower.endsWith('lich') ||
        lower.endsWith('ig') ||
        lower.endsWith('isch') ||
        lower.endsWith('bar')) {
      return GermanPartOfSpeech.adjective;
    }
    return GermanPartOfSpeech.unknown;
  }

  void _checkSentenceCapitalisation(
    List<GermanToken> tokens,
    List<GrammarFinding> findings,
  ) {
    if (tokens.isEmpty) return;
    final first = tokens.first;
    if (RegExp(r'^[a-zäöüß]').hasMatch(first.text)) {
      findings.add(GrammarFinding(
        ruleId: 'DE-CAP-001',
        message: 'Start the sentence with a capital letter.',
        explanation:
            'In German, the first word of a sentence begins with a capital letter.',
        severity: GrammarSeverity.warning,
        start: first.start,
        length: first.text.length,
        suggestion: '${first.text[0].toUpperCase()}${first.text.substring(1)}',
      ));
    }
  }

  void _checkKnownNounCapitalisation(
    List<GermanToken> tokens,
    List<GrammarFinding> findings,
  ) {
    for (final token in tokens) {
      final lower = token.text.toLowerCase();
      if (_knownNouns.contains(lower) && token.text == lower) {
        findings.add(GrammarFinding(
          ruleId: 'DE-CAP-002',
          message: 'German nouns begin with a capital letter.',
          explanation:
              '"${token.text}" is a noun. Write it with an initial capital.',
          severity: GrammarSeverity.warning,
          start: token.start,
          length: token.text.length,
          suggestion:
              '${token.text[0].toUpperCase()}${token.text.substring(1)}',
        ));
      }
    }
  }

  void _checkKnownVerbAgreement(
    List<GermanToken> tokens,
    List<GrammarFinding> findings,
  ) {
    const expected = {
      'ich|sein': 'bin',
      'du|sein': 'bist',
      'er|sein': 'ist',
      'sie|sein': 'ist',
      'es|sein': 'ist',
      'wir|sein': 'sind',
      'ihr|sein': 'seid',
      'Sie|sein': 'sind',
      'ich|haben': 'habe',
      'du|haben': 'hast',
      'er|haben': 'hat',
      'sie|haben': 'hat',
      'es|haben': 'hat',
      'wir|haben': 'haben',
      'ihr|haben': 'habt',
      'Sie|haben': 'haben',
    };
    for (var i = 0; i + 1 < tokens.length; i++) {
      final subject = tokens[i].text;
      final subjectKey = subject == 'Sie' ? 'Sie' : subject.toLowerCase();
      final verb = tokens[i + 1];
      final lemma = _verbLemmas[verb.text.toLowerCase()];
      if (lemma == null) continue;
      final correct = expected['$subjectKey|$lemma'];
      if (correct != null && correct != verb.text.toLowerCase()) {
        findings.add(GrammarFinding(
          ruleId: 'DE-VERB-001',
          message: 'Check the verb form for "$subject".',
          explanation:
              'The verb "$lemma" changes according to the subject. With "$subject", use "$correct".',
          severity: GrammarSeverity.error,
          start: verb.start,
          length: verb.text.length,
          suggestion: correct,
        ));
      }
    }
  }

  void _checkKnownArticleGender(
    List<GermanToken> tokens,
    List<GrammarFinding> findings,
  ) {
    const articleGender = {
      'der': 'der',
      'den': 'der',
      'dem': 'der',
      'des': 'der',
      'die': 'die',
      'das': 'das',
    };
    for (var i = 0; i + 1 < tokens.length; i++) {
      final article = tokens[i];
      final noun = tokens[i + 1];
      final expectedGender = _nounGenders[noun.text.toLowerCase()];
      final actualGender = articleGender[article.text.toLowerCase()];
      if (expectedGender == null ||
          actualGender == null ||
          expectedGender == actualGender) {
        continue;
      }
      findings.add(GrammarFinding(
        ruleId: 'DE-ARTICLE-001',
        message: 'Check the article for "${noun.text}".',
        explanation:
            'The dictionary gender of "${noun.text}" is $expectedGender. Case can change the article form.',
        severity: GrammarSeverity.warning,
        start: article.start,
        length: article.text.length,
        suggestion: expectedGender,
      ));
    }
  }

  void _checkSimpleVerbSecondOrder(
    List<GermanToken> tokens,
    List<GrammarFinding> findings,
  ) {
    if (tokens.length < 3) return;
    final subject = tokens[0].text.toLowerCase();
    final adverb = tokens[1].text.toLowerCase();
    final verb = tokens[2];
    if (!_pronouns.contains(subject) ||
        !_timeAdverbs.contains(adverb) ||
        !_verbLemmas.containsKey(verb.text.toLowerCase())) {
      return;
    }
    findings.add(GrammarFinding(
      ruleId: 'DE-WORD-ORDER-001',
      message:
          'In a simple main clause, the conjugated verb is usually in position two.',
      explanation:
          'Move the conjugated verb directly after the subject: "${tokens[0].text} ${verb.text} ${tokens[1].text}".',
      severity: GrammarSeverity.warning,
      start: verb.start,
      length: verb.text.length,
      suggestion: '${tokens[0].text} ${verb.text} ${tokens[1].text}',
    ));
  }
}
