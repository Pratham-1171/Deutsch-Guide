import 'german_nlp_engine.dart';

/// Small, explicit A1 vocabulary resource. Unknown words stay unknown rather
/// than being guessed from spelling alone.
class GermanLexicon {
  const GermanLexicon();

  static const pronouns = {
    'ich', 'du', 'er', 'sie', 'es', 'wir', 'ihr', 'Sie',
  };

  static const articles = {
    'der', 'die', 'das', 'den', 'dem', 'des',
    'ein', 'eine', 'einen', 'einem', 'einer', 'eines',
  };

  static const prepositions = {
    'an', 'auf', 'aus', 'bei', 'bis', 'durch', 'für', 'gegen',
    'mit', 'nach', 'seit', 'von', 'zu', 'in', 'im', 'ins',
    'über', 'unter', 'vor', 'hinter', 'neben', 'zwischen',
  };

  static const conjunctions = {'und', 'oder', 'aber', 'denn'};

  static const nounGenders = <String, String>{
    'mann': 'der', 'hund': 'der', 'kaffee': 'der', 'tee': 'der',
    'apfel': 'der', 'zug': 'der', 'morgen': 'der', 'abend': 'der',
    'tag': 'der', 'name': 'der', 'freund': 'der',
    'frau': 'die', 'katze': 'die', 'schule': 'die',
    'universität': 'die', 'stadt': 'die', 'arbeit': 'die',
    'sprache': 'die', 'frage': 'die', 'antwort': 'die',
    'zeit': 'die', 'familie': 'die', 'mutter': 'die',
    'schwester': 'die', 'freundin': 'die',
    'buch': 'das', 'kind': 'das', 'haus': 'das', 'land': 'das',
    'wasser': 'das', 'auto': 'das', 'zimmer': 'das',
  };

  static const _verbs = <String, String>{
    'bin': 'sein', 'bist': 'sein', 'ist': 'sein', 'sind': 'sein',
    'seid': 'sein', 'war': 'sein', 'waren': 'sein',
    'habe': 'haben', 'hast': 'haben', 'hat': 'haben',
    'haben': 'haben', 'habt': 'haben',
    'komme': 'kommen', 'kommst': 'kommen', 'kommt': 'kommen',
    'kommen': 'kommen',
    'wohne': 'wohnen', 'wohnst': 'wohnen', 'wohnt': 'wohnen',
    'wohnen': 'wohnen',
    'lerne': 'lernen', 'lernst': 'lernen', 'lernt': 'lernen',
    'lernen': 'lernen',
    'mache': 'machen', 'machst': 'machen', 'macht': 'machen',
    'machen': 'machen',
    'gehe': 'gehen', 'gehst': 'gehen', 'geht': 'gehen', 'gehen': 'gehen',
    'spreche': 'sprechen', 'sprichst': 'sprechen',
    'spricht': 'sprechen', 'sprecht': 'sprechen', 'sprechen': 'sprechen',
  };

String lemmaFor(String lower) => _verbs[lower] ?? lower;

  GermanPartOfSpeech partOfSpeechFor(String value) {
    final lower = value.toLowerCase();
    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return GermanPartOfSpeech.number;
    }
    if (RegExp(r'^[^A-Za-zÄÖÜäöüß0-9]$', unicode: true).hasMatch(value)) {
      return GermanPartOfSpeech.punctuation;
    }
    if (pronouns.contains(value) || pronouns.contains(lower)) {
      return GermanPartOfSpeech.pronoun;
    }
    if (articles.contains(lower)) return GermanPartOfSpeech.article;
    if (_verbs.containsKey(lower)) return GermanPartOfSpeech.verb;
    if (prepositions.contains(lower)) return GermanPartOfSpeech.preposition;
    if (conjunctions.contains(lower)) return GermanPartOfSpeech.conjunction;
    if (nounGenders.containsKey(lower)) return GermanPartOfSpeech.noun;
    if (lower.endsWith('lich') || lower.endsWith('ig') ||
        lower.endsWith('isch') || lower.endsWith('bar')) {
      return GermanPartOfSpeech.adjective;
    }
    return GermanPartOfSpeech.unknown;
  }
}
