import 'german_lexicon.dart';
import 'german_nlp_models.dart';

/// Splits German text while preserving Dart string offsets for UI highlighting.
class GermanTokenizer {
  const GermanTokenizer();

  static final _pattern = RegExp(
    r'[A-Za-zÄÖÜäöüß]+|[0-9]+|[^\s]',
    unicode: true,
  );

  List<GermanToken> tokenize(String text, GermanLexicon lexicon) {
    return _pattern.allMatches(text).map((match) {
      final value = match.group(0)!;
      final lower = value.toLowerCase();
      return GermanToken(
        text: value,
        lemma: lexicon.lemmaFor(lower),
        partOfSpeech: lexicon.partOfSpeechFor(value),
        start: match.start,
        end: match.end,
      );
    }).toList(growable: false);
  }
}
