import 'package:flutter/foundation.dart';

enum ExerciseType { singleChoice, shortAnswer }

@immutable
class Curriculum {
  const Curriculum({
    required this.contentVersion,
    required this.schemaVersion,
    required this.locale,
    required this.level,
    required this.title,
    required this.description,
    required this.units,
  });

  final int contentVersion;
  final int schemaVersion;
  final String locale;
  final String level;
  final String title;
  final String description;
  final List<CurriculumUnit> units;

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    final contentVersion = _requiredInt(json, 'contentVersion');
    final schemaVersion = _requiredInt(json, 'schemaVersion');
    if (contentVersion < 1 || schemaVersion != 1) {
      throw const FormatException('Unsupported curriculum version.');
    }

    final unitsJson = json['units'];
    if (unitsJson is! List) {
      throw const FormatException('Curriculum units must be a list.');
    }

    final curriculum = Curriculum(
      contentVersion: contentVersion,
      schemaVersion: schemaVersion,
      locale: _requiredString(json, 'locale'),
      level: _requiredString(json, 'level'),
      title: _requiredString(json, 'title'),
      description: _requiredString(json, 'description'),
      units: unitsJson
          .map((item) => CurriculumUnit.fromJson(_asMap(item, 'unit')))
          .toList(growable: false),
    );
    curriculum.validate();
    return curriculum;
  }

  void validate() {
    if (units.isEmpty) {
      throw const FormatException(
        'A curriculum must contain at least one unit.',
      );
    }
    final ids = <String>{};
    void addId(String id) {
      if (!ids.add(id)) {
        throw FormatException('Duplicate curriculum ID: $id');
      }
    }

    for (final unit in units) {
      addId(unit.id);
      if (unit.lessons.isEmpty) {
        throw FormatException('Unit ${unit.id} has no lessons.');
      }
      for (final lesson in unit.lessons) {
        addId(lesson.id);
        if (lesson.objectives.isEmpty || lesson.exercises.isEmpty) {
          throw FormatException(
            'Lesson ${lesson.id} needs an objective and an exercise.',
          );
        }
        for (final exercise in lesson.exercises) {
          addId(exercise.id);
          if (exercise.type == ExerciseType.singleChoice &&
              (exercise.options.length < 2 ||
                  !exercise.options.contains(exercise.answer))) {
            throw FormatException(
              'Single-choice exercise ${exercise.id} has invalid options.',
            );
          }
        }
      }
    }
  }
}

@immutable
class CurriculumUnit {
  const CurriculumUnit({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final List<CurriculumLesson> lessons;

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    final lessons = json['lessons'];
    if (lessons is! List) {
      throw const FormatException('Unit lessons must be a list.');
    }
    return CurriculumUnit(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      description: _requiredString(json, 'description'),
      lessons: lessons
          .map((item) => CurriculumLesson.fromJson(_asMap(item, 'lesson')))
          .toList(growable: false),
    );
  }
}

@immutable
class CurriculumLesson {
  const CurriculumLesson({
    required this.id,
    required this.title,
    required this.objectives,
    required this.chunks,
    required this.exercises,
  });

  final String id;
  final String title;
  final List<String> objectives;
  final List<LearningChunk> chunks;
  final List<CurriculumExercise> exercises;

  factory CurriculumLesson.fromJson(Map<String, dynamic> json) {
    return CurriculumLesson(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      objectives: _stringList(json, 'objectives'),
      chunks: _objectList(json, 'chunks', LearningChunk.fromJson),
      exercises: _objectList(json, 'exercises', CurriculumExercise.fromJson),
    );
  }
}

@immutable
class LearningChunk {
  const LearningChunk({required this.german, required this.english});

  final String german;
  final String english;

  factory LearningChunk.fromJson(Map<String, dynamic> json) => LearningChunk(
        german: _requiredString(json, 'de'),
        english: _requiredString(json, 'en'),
      );
}

@immutable
class CurriculumExercise {
  const CurriculumExercise({
    required this.id,
    required this.type,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.options = const [],
    this.acceptedAnswers = const [],
    this.grammarRuleIds = const [],
  });

  final String id;
  final ExerciseType type;
  final String prompt;
  final String answer;
  final String explanation;
  final List<String> options;
  final List<String> acceptedAnswers;

  /// Stable offline NLP rules relevant to this exercise's German response.
  /// These IDs only enable feedback; they never change answer evaluation.
  final List<String> grammarRuleIds;

  bool isCorrect(String response) {
    String normalise(String value) => value.trim().toLowerCase();

    final accepted = <String>{answer, ...acceptedAnswers}.map(normalise);
    return accepted.contains(normalise(response));
  }

  factory CurriculumExercise.fromJson(Map<String, dynamic> json) {
    final typeName = _requiredString(json, 'type');
    final type = switch (typeName) {
      'single_choice' => ExerciseType.singleChoice,
      'short_answer' => ExerciseType.shortAnswer,
      _ => throw FormatException('Unsupported exercise type: $typeName'),
    };
    return CurriculumExercise(
      id: _requiredString(json, 'id'),
      type: type,
      prompt: _requiredString(json, 'prompt'),
      answer: _requiredString(json, 'answer'),
      explanation: _requiredString(json, 'explanation'),
      options: _stringList(json, 'options', optional: true),
      acceptedAnswers: _stringList(json, 'acceptedAnswers', optional: true),
      grammarRuleIds: _stringList(json, 'grammarRuleIds', optional: true),
    );
  }
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) throw FormatException('Missing or invalid $key.');
  return value;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid $key.');
  }
  return value;
}

Map<String, dynamic> _asMap(Object? value, String label) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Invalid $label object.');
}

List<String> _stringList(
  Map<String, dynamic> json,
  String key, {
  bool optional = false,
}) {
  final value = json[key];
  if (optional && value == null) return const [];
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('Missing or invalid $key list.');
  }
  return value.cast<String>();
}

List<T> _objectList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) parse,
) {
  final value = json[key];
  if (value is! List) throw FormatException('Missing or invalid $key list.');
  return value.map((item) => parse(_asMap(item, key))).toList(growable: false);
}
