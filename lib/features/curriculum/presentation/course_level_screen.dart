import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../data/curriculum_repository.dart';

class CourseLevelScreen extends ConsumerWidget {
  const CourseLevelScreen({required this.level, super.key});

  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculum = ref.watch(curriculumProvider(level));
    return Scaffold(
      appBar: AppBar(title: Text('German $level')),
      body: curriculum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, size: 40),
                const SizedBox(height: 12),
                Text(
                  error is UnsupportedError
                      ? 'This level is not available yet.'
                      : 'We could not load this course.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(curriculumProvider(level)),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (course) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(course.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(course.description),
            const SizedBox(height: 20),
            for (var unitIndex = 0; unitIndex < course.units.length; unitIndex++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit ${unitIndex + 1}: ${course.units[unitIndex].title}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(course.units[unitIndex].description),
                      const SizedBox(height: 8),
                      for (var lessonIndex = 0;
                          lessonIndex < course.units[unitIndex].lessons.length;
                          lessonIndex++)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text('${lessonIndex + 1}'),
                          ),
                          title: Text(
                            course.units[unitIndex].lessons[lessonIndex].title,
                          ),
                          subtitle: Text(
                            '${course.units[unitIndex].lessons[lessonIndex].objectives.length} learning objectives',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.pushNamed(
                            AppRoutes.lesson.name,
                            pathParameters: {
                              'lessonId':
                                  course.units[unitIndex].lessons[lessonIndex].id,
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
