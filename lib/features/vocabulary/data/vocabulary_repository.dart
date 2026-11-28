import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GermanArticle { der, die, das }

class VocabularyEntry {
  const VocabularyEntry({
    required this.id,
    required this.lemma,
    required this.article,
    required this.plural,
    required this.meaningEn,
    required this.topicId,
    required this.exampleDe,
    required this.exampleEn,
    required this.level,
  });

  final String id;
  final String lemma;
  final GermanArticle article;
  final String? plural;
  final String meaningEn;
  final String topicId;
  final String exampleDe;
  final String exampleEn;
  final String level;

  factory VocabularyEntry.fromJson(Map<String, dynamic> json) {
    final articleName = json['article'];
    final article = GermanArticle.values.where(
      (value) => value.name == articleName,
    );
    if (article.isEmpty) {
      throw const FormatException('Vocabulary noun has an invalid article.');
    }
    final plural = json['plural'];
    if (plural != null && plural is! String) {
      throw const FormatException('Vocabulary plural must be text or null.');
    }
    return VocabularyEntry(
      id: _requiredText(json, 'id'),
      lemma: _requiredText(json, 'lemma'),
      article: article.single,
      plural: plural as String?,
      meaningEn: _requiredText(json, 'meaningEn'),
      topicId: _requiredText(json, 'topicId'),
      exampleDe: _requiredText(json, 'exampleDe'),
      exampleEn: _requiredText(json, 'exampleEn'),
      level: _requiredText(json, 'level'),
    );
  }
}

class VocabularyCatalog {
  const VocabularyCatalog({
    required this.contentVersion,
    required this.schemaVersion,
    required this.level,
    required this.entries,
  });

  final int contentVersion;
  final int schemaVersion;
  final String level;
  final List<VocabularyEntry> entries;

  factory VocabularyCatalog.fromJson(Map<String, dynamic> json) {
    final contentVersion = json['contentVersion'];
    final schemaVersion = json['schemaVersion'];
    final rawEntries = json['entries'];
    if (contentVersion is! int ||
        contentVersion < 1 ||
        schemaVersion != 1 ||
        rawEntries is! List) {
      throw const FormatException('Unsupported vocabulary catalog format.');
    }
    final catalog = VocabularyCatalog(
      contentVersion: contentVersion,
      schemaVersion: schemaVersion as int,
      level: _requiredText(json, 'level'),
      entries: rawEntries.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Vocabulary entry must be an object.');
        }
        return VocabularyEntry.fromJson(item);
      }).toList(growable: false),
    );
    catalog.validate();
    return catalog;
  }

  void validate() {
    if (entries.isEmpty) {
      throw const FormatException('Vocabulary catalog cannot be empty.');
    }
    final ids = <String>{};
    final lemmas = <String>{};
    for (final entry in entries) {
      if (!ids.add(entry.id)) {
        throw FormatException('Duplicate vocabulary ID: ${entry.id}');
      }
      if (!lemmas.add(entry.lemma.toLowerCase())) {
        throw FormatException('Duplicate vocabulary lemma: ${entry.lemma}');
      }
      if (entry.level != level) {
        throw FormatException('Mixed CEFR levels in vocabulary catalog.');
      }
      if (entry.plural != null && entry.plural!.trim().isEmpty) {
        throw FormatException('Empty plural form for ${entry.lemma}.');
      }
    }
  }
}

String _requiredText(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid vocabulary field: $key.');
  }
  return value;
}

class VocabularyRepository {
  const VocabularyRepository();

  Future<VocabularyCatalog> loadLevel(String level) async {
    if (level.toUpperCase() != 'A1') {
      throw UnsupportedError('The $level vocabulary is not available yet.');
    }
    final source = await rootBundle.loadString(
      'assets/learning_content/v1/a1_vocabulary.json',
    );
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Vocabulary catalog root must be an object.');
    }
    return VocabularyCatalog.fromJson(decoded);
  }
}

final vocabularyRepositoryProvider = Provider<VocabularyRepository>(
  (ref) => const VocabularyRepository(),
);

final vocabularyCatalogProvider =
    FutureProvider.family<VocabularyCatalog, String>((ref, level) {
  return ref.watch(vocabularyRepositoryProvider).loadLevel(level);
});
