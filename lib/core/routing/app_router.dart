import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/profile/presentation/learner_dashboard_screen.dart';
import '../../features/curriculum/presentation/course_level_screen.dart';
import '../../features/lessons/presentation/lesson_player_screen.dart';
import '../../features/nlp/presentation/german_grammar_screen.dart';
import '../../features/profile/presentation/profile_form_screen.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../shared/widgets/placeholder_screen.dart';
import 'app_routes.dart';
import 'auth_refresh_notifier.dart';

GoRoute _simple(AppRoute route, String title) {
  return GoRoute(
    name: route.name,
    path: route.path,
    builder: (context, state) => PlaceholderScreen(title: title),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = AppConfig.hasSupabase
      ? AuthRefreshNotifier(Supabase.instance.client)
      : null;

  final router = GoRouter(
    initialLocation: AppRoutes.dashboard.path,
    refreshListenable: authRefresh,
    redirect: (context, state) async {
      // Keep the original demo experience when no Supabase config is passed.
      if (!AppConfig.hasSupabase) return null;

      final path = state.matchedLocation;
      final isSignIn = path == AppRoutes.signIn.path;
      final isSignUp = path == AppRoutes.signUp.path;
      final isForgotPassword = path == AppRoutes.forgotPassword.path;
      final isResetPassword = path == AppRoutes.resetPassword.path;
      final isOnboarding = path == AppRoutes.onboarding.path;
      final isPublicAuthRoute =
          isSignIn || isSignUp || isForgotPassword || isResetPassword;
      final hasSession = Supabase.instance.client.auth.currentSession != null;

      if (authRefresh?.isPasswordRecovery == true) {
        return isResetPassword ? null : AppRoutes.resetPassword.path;
      }

      if (isResetPassword && authRefresh?.isPasswordRecovery != true) {
        return hasSession ? AppRoutes.dashboard.path : AppRoutes.signIn.path;
      }

      if (!hasSession && !isPublicAuthRoute) {
        final destination = state.uri.toString();
        return Uri(
          path: AppRoutes.signIn.path,
          queryParameters: destination == '/' ? null : {'next': destination},
        ).toString();
      }

      if (hasSession && (isSignIn || isSignUp || isForgotPassword)) {
        return AppRoutes.dashboard.path;
      }

      if (hasSession) {
        try {
          final profile = await ref.read(learnerProfileProvider.future);
          final needsOnboarding = profile == null || !profile.isComplete;

          if (needsOnboarding && !isOnboarding) {
            return AppRoutes.onboarding.path;
          }
          if (!needsOnboarding && isOnboarding) {
            return AppRoutes.dashboard.path;
          }
        } catch (_) {
          // Let the destination screen show a retry state if the profile
          // service is temporarily unavailable.
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        name: AppRoutes.signIn.name,
        path: AppRoutes.signIn.path,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        name: AppRoutes.signUp.name,
        path: AppRoutes.signUp.path,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: AppRoutes.forgotPassword.name,
        path: AppRoutes.forgotPassword.path,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: AppRoutes.resetPassword.name,
        path: AppRoutes.resetPassword.path,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        name: AppRoutes.dashboard.name,
        path: AppRoutes.dashboard.path,
        builder: (context, state) => AppConfig.hasSupabase
            ? const LearnerDashboardScreen()
            : const _DemoDashboardScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboarding.name,
        path: AppRoutes.onboarding.path,
        builder: (context, state) =>
            const ProfileFormScreen(isOnboarding: true),
      ),
      GoRoute(
        name: AppRoutes.profile.name,
        path: AppRoutes.profile.path,
        builder: (context, state) =>
            const ProfileFormScreen(isOnboarding: false),
      ),
      GoRoute(
        name: AppRoutes.courseLevel.name,
        path: AppRoutes.courseLevel.path,
        builder: (context, state) => CourseLevelScreen(
          level: state.pathParameters['level']!,
        ),
      ),
      GoRoute(
        name: AppRoutes.lesson.name,
        path: AppRoutes.lesson.path,
        builder: (context, state) => LessonPlayerScreen(
          lessonId: state.pathParameters['lessonId']!,
        ),
      ),
      GoRoute(
        name: AppRoutes.grammar.name,
        path: AppRoutes.grammar.path,
        builder: (context, state) => const GermanGrammarScreen(),
      ),
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

  ref.listen(learnerProfileProvider, (previous, next) {
    router.refresh();
  });

  ref.onDispose(() {
    router.dispose();
    authRefresh?.dispose();
  });
  return router;
});

/// Keeps the no-Supabase demo mode available for UI development.
class _DemoDashboardScreen extends ConsumerWidget {
  const _DemoDashboardScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final currentUser = authRepository?.currentUser;
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
      ('Progress', AppRoutes.progress),
      ('Settings', AppRoutes.settings),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (currentUser != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: () async {
                await authRepository!.signOut();
              },
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: ListView(
        children: [
          if (currentUser != null)
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(currentUser.email ?? 'Signed in'),
              subtitle: const Text('Signed in account'),
            ),
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
              onTap: () => context.pushNamed(route.name),
            ),
        ],
      ),
    );
  }
}
