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
