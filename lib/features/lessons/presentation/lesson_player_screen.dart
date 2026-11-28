import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../curriculum/data/curriculum_repository.dart';
import '../../curriculum/domain/curriculum.dart';
import '../../nlp/domain/german_nlp_engine.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({required this.lessonId, super.key});

  final String lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  final _answerController = TextEditingController();
  String? _selectedOption;
  bool _hasChecked = false;
  bool _complete = false;
  int _exerciseIndex = 0;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _resetAnswer() {
    _answerController.clear();
    _selectedOption = null;
    _hasChecked = false;
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(curriculumProvider('a1'));
    return course.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: Text('This lesson could not be loaded.')),
      ),
      data: (curriculum) {
        CurriculumLesson? lesson;
        for (final unit in curriculum.units) {
          for (final candidate in unit.lessons) {
            if (candidate.id == widget.lessonId) lesson = candidate;
          }
        }
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lesson')),
            body: const Center(child: Text('Lesson not found.')),
          );
        }
        if (_complete) {
          return Scaffold(
            appBar: AppBar(title: Text(lesson.title)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.celebration_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'Lesson complete!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('You finished all activities in this lesson.'),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to course'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final exercise = lesson.exercises[_exerciseIndex];
        final response = exercise.type == ExerciseType.singleChoice
            ? (_selectedOption ?? '')
            : _answerController.text;
        final isCorrect = _hasChecked && exercise.isCorrect(response);
        final grammarFindings = _hasChecked &&
                !isCorrect &&
                exercise.grammarRuleIds.isNotEmpty
            ? const GermanNlpEngine()
                .analyze(response)
                .findings
                .where((finding) =>
                    exercise.grammarRuleIds.contains(finding.ruleId))
                .toList(growable: false)
            : const <GrammarFinding>[];
        return Scaffold(
          appBar: AppBar(title: Text(lesson.title)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Learning goals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final objective in lesson.objectives)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(objective)),
                      ],
                    ),
                  ),
                if (lesson.chunks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Useful German chunks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  for (final chunk in lesson.chunks)
                    Card(
                      child: ListTile(
                        title: Text(chunk.german),
                        subtitle: Text(chunk.english),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: (_exerciseIndex + 1) / lesson.exercises.length,
                ),
                const SizedBox(height: 8),
                Text(
                  'Practice ${_exerciseIndex + 1} of ${lesson.exercises.length}',
                ),
                const SizedBox(height: 12),
                Text(
                  exercise.prompt,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (exercise.type == ExerciseType.singleChoice)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in exercise.options)
                        ChoiceChip(
                          label: Text(option),
                          selected: _selectedOption == option,
                          onSelected: _hasChecked
                              ? null
                              : (_) => setState(() => _selectedOption = option),
                        ),
                    ],
                  )
                else
                  TextField(
                    controller: _answerController,
                    enabled: !_hasChecked,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your answer',
                    ),
                  ),
                if (_hasChecked) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: isCorrect
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(isCorrect ? 'Correct!' : 'Not quite yet'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(exercise.explanation),
                          if (!isCorrect)
                            Text('Correct answer: ${exercise.answer}'),
                          if (!isCorrect &&
                              exercise.grammarRuleIds.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            Text(
                              'Offline grammar hint',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            if (grammarFindings.isEmpty)
                              const Text(
                                'No matching issue was found by the current offline rules. Coverage is limited to selected A1 patterns.',
                              )
                            else
                              for (final finding in grammarFindings) ...[
                                Text(finding.message),
                                const SizedBox(height: 4),
                                Text(finding.explanation),
                                if (finding.suggestion != null)
                                  Text('Suggestion: ${finding.suggestion}'),
                                const SizedBox(height: 6),
                              ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: !_hasChecked
                      ? (exercise.type == ExerciseType.singleChoice
                          ? (_selectedOption == null
                              ? null
                              : () => setState(() => _hasChecked = true))
                          : (_answerController.text.trim().isEmpty
                              ? null
                              : () => setState(() => _hasChecked = true)))
                      : () {
                          if (_exerciseIndex + 1 == lesson!.exercises.length) {
                            setState(() => _complete = true);
                          } else {
                            setState(() {
                              _exerciseIndex++;
                              _resetAnswer();
                            });
                          }
                        },
                  child: Text(
                    !_hasChecked
                        ? 'Check answer'
                        : (_exerciseIndex + 1 == lesson.exercises.length
                            ? 'Finish lesson'
                            : 'Next activity'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
