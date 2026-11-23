import 'package:deutsch_guide/features/curriculum/data/curriculum_repository.dart';
import 'package:deutsch_guide/features/curriculum/domain/curriculum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('A1 curriculum', () {
    test(
      'loads versioned units, lessons and exercises from the asset',
      () async {
        const repository = CurriculumRepository();
        final curriculum = await repository.loadLevel('A1');

        expect(curriculum.level, 'A1');
        expect(curriculum.schemaVersion, 1);
        expect(curriculum.units, isNotEmpty);
        expect(curriculum.units.first.lessons, isNotEmpty);
        expect(curriculum.units.first.lessons.first.exercises, isNotEmpty);
      },
    );

    test('rejects unsupported exercise types', () {
      expect(
        () => CurriculumExercise.fromJson({
          'id': 'bad-exercise',
          'type': 'drag_and_drop',
          'prompt': 'Move the words.',
          'answer': 'Hallo',
          'explanation': 'Try again.',
        }),
        throwsFormatException,
      );
    });

    test(
      'checks short answers without case or outer whitespace sensitivity',
      () {
        const exercise = CurriculumExercise(
          id: 'answer-1',
          type: ExerciseType.shortAnswer,
          prompt: 'Write hello.',
          answer: 'Hallo!',
          explanation: 'Hallo is a greeting.',
        );

        expect(exercise.isCorrect('  hallo!  '), isTrue);
        expect(exercise.isCorrect('Guten Tag'), isFalse);
      },
    );

    test('rejects duplicate IDs across curriculum objects', () {
      expect(
        () => Curriculum.fromJson({
          'contentVersion': 1,
          'schemaVersion': 1,
          'locale': 'de',
          'level': 'A1',
          'title': 'Test',
          'description': 'Test curriculum',
          'units': [
            {
              'id': 'same-id',
              'title': 'Unit',
              'description': 'Description',
              'lessons': [
                {
                  'id': 'same-id',
                  'title': 'Lesson',
                  'objectives': ['Say hello'],
                  'chunks': [],
                  'exercises': [
                    {
                      'id': 'exercise-id',
                      'type': 'short_answer',
                      'prompt': 'Say hello.',
                      'answer': 'Hallo',
                      'explanation': 'Hallo is hello.',
                    },
                  ],
                },
              ],
            },
          ],
        }),
        throwsFormatException,
      );
    });

    test('ships the complete ten-unit A1 learning pathway', () async {
      const repository = CurriculumRepository();
      final curriculum = await repository.loadLevel('A1');

      expect(curriculum.units, hasLength(10));
      expect(
        curriculum.units.fold<int>(
          0,
          (count, unit) => count + unit.lessons.length,
        ),
        20,
      );
      expect(
        curriculum.units.fold<int>(
          0,
          (count, unit) => count + unit.lessons.fold<int>(
            0,
            (lessonCount, lesson) => lessonCount + lesson.exercises.length,
          ),
        ),
        60,
      );
    });

    test('every A1 lesson has objectives, phrase chunks and practice', () async {
      const repository = CurriculumRepository();
      final curriculum = await repository.loadLevel('A1');

      for (final unit in curriculum.units) {
        expect(unit.description, isNotEmpty, reason: unit.id);
        for (final lesson in unit.lessons) {
          expect(lesson.objectives, isNotEmpty, reason: lesson.id);
          expect(lesson.chunks, isNotEmpty, reason: lesson.id);
          expect(
            lesson.exercises.length,
            greaterThanOrEqualTo(3),
            reason: lesson.id,
          );
          for (final exercise in lesson.exercises) {
            expect(exercise.prompt, isNotEmpty, reason: exercise.id);
            expect(exercise.answer, isNotEmpty, reason: exercise.id);
            expect(exercise.explanation, isNotEmpty, reason: exercise.id);
            if (exercise.type == ExerciseType.singleChoice) {
              expect(
                exercise.options,
                contains(exercise.answer),
                reason: exercise.id,
              );
            }
          }
        }
      }
    });
  });
}
