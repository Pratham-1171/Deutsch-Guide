import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/placeholder_screen.dart';
import 'app_routes.dart';

GoRoute _simple(AppRoute route, String title) {
  return GoRoute(
    name: route.name,
    path: route.path,
    builder: (context, state) => PlaceholderScreen(title: title),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard.path,
    // Route guards (redirect on sign-in state and role) are added in Phase 3.
    routes: [
      _simple(AppRoutes.signIn, 'Sign in'),
      _simple(AppRoutes.signUp, 'Sign up'),
      GoRoute(
        name: AppRoutes.dashboard.name,
        path: AppRoutes.dashboard.path,
        builder: (context, state) => const _DashboardScreen(),
      ),
      GoRoute(
        name: AppRoutes.courseLevel.name,
        path: AppRoutes.courseLevel.path,
        builder: (context, state) => PlaceholderScreen(
          title: 'Level ${state.pathParameters['level']!.toUpperCase()}',
        ),
      ),
      GoRoute(
        name: AppRoutes.lesson.name,
        path: AppRoutes.lesson.path,
        builder: (context, state) => PlaceholderScreen(
          title: 'Lesson ${state.pathParameters['lessonId']}',
        ),
      ),
      _simple(AppRoutes.grammar, 'Grammar'),
      _simple(AppRoutes.vocabulary, 'Vocabulary'),
      _simple(AppRoutes.dictionary, 'Dictionary'),
      _simple(AppRoutes.verbs, 'Verbs'),
      _simple(AppRoutes.reading, 'Reading'),
      _simple(AppRoutes.listening, 'Listening'),
      _simple(AppRoutes.writing, 'Writing'),
      _simple(AppRoutes.speaking, 'Speaking'),
      _simple(AppRoutes.practice, 'Practice'),
      _simple(AppRoutes.assignments, 'Assignments'),
      _simple(AppRoutes.teacher, 'Teacher workspace'),
      _simple(AppRoutes.progress, 'Progress'),
      _simple(AppRoutes.settings, 'Settings'),
    ],
    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: 'Page not found'),
  );

  ref.onDispose(router.dispose);
  return router;
});

/// Temporary dashboard that links to every section while features are built.
class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    final entries = <(String, AppRoute)>[
      ('Grammar', AppRoutes.grammar),
      ('Vocabulary', AppRoutes.vocabulary),
      ('Dictionary', AppRoutes.dictionary),
      ('Verbs', AppRoutes.verbs),
      ('Reading', AppRoutes.reading),
      ('Listening', AppRoutes.listening),
      ('Writing', AppRoutes.writing),
      ('Speaking', AppRoutes.speaking),
      ('Practice', AppRoutes.practice),
      ('Assignments', AppRoutes.assignments),
      ('Teacher workspace', AppRoutes.teacher),
      ('Progress', AppRoutes.progress),
      ('Settings', AppRoutes.settings),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Level A1'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(
              AppRoutes.courseLevel.name,
              pathParameters: {'level': 'a1'},
            ),
          ),
          for (final (label, route) in entries)
            ListTile(
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed(route.name),
            ),
        ],
      ),
    );
  }
}
