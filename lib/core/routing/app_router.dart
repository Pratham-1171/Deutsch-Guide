import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
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
    redirect: (context, state) {
      // Keep the original demo experience when no Supabase config is passed.
      if (!AppConfig.hasSupabase) return null;

      final path = state.matchedLocation;
      final isSignIn = path == AppRoutes.signIn.path;
      final isSignUp = path == AppRoutes.signUp.path;
      final isForgotPassword = path == AppRoutes.forgotPassword.path;
      final isResetPassword = path == AppRoutes.resetPassword.path;
      final isPublicAuthRoute =
          isSignIn || isSignUp || isForgotPassword || isResetPassword;
      final hasSession = Supabase.instance.client.auth.currentSession != null;

      if (authRefresh?.isPasswordRecovery == true) {
        return isResetPassword ? null : AppRoutes.resetPassword.path;
      }

      if (isResetPassword && authRefresh?.isPasswordRecovery != true) {
        return hasSession
            ? AppRoutes.dashboard.path
            : AppRoutes.signIn.path;
      }

      if (!hasSession && !isPublicAuthRoute) {
        final destination = state.uri.toString();
        return Uri(
          path: AppRoutes.signIn.path,
          queryParameters: destination == '/'
              ? null
              : {'next': destination},
        ).toString();
      }

      if (hasSession && (isSignIn || isSignUp || isForgotPassword)) {
        return AppRoutes.dashboard.path;
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
        builder: (context, state) =>
            PlaceholderScreen(title: 'Lesson ${state.pathParameters['lessonId']}'),
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

  ref.onDispose(() {
    router.dispose();
    authRefresh?.dispose();
  });
  return router;
});

/// Temporary dashboard that links to every section while features are built.
class _DashboardScreen extends ConsumerWidget {
  const _DashboardScreen();

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
      ('Teacher workspace', AppRoutes.teacher),
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
              onTap: () => context.goNamed(route.name),
            ),
        ],
      ),
    );
  }
}
