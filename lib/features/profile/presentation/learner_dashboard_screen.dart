import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/learner_profile.dart';
import '../providers/profile_providers.dart';
import 'profile_form_screen.dart';

class LearnerDashboardScreen extends ConsumerWidget {
  const LearnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(learnerProfileProvider).when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text('Deutsch Guide')),
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Deutsch Guide')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 40),
                    const SizedBox(height: 12),
                    const Text('We could not load your learner profile.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(learnerProfileProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (profile) {
            if (profile == null || !profile.isComplete) {
              return const ProfileFormScreen(isOnboarding: true);
            }
            return _LearnerHome(profile: profile);
          },
        );
  }
}

class _LearnerHome extends ConsumerWidget {
  const _LearnerHome({required this.profile});

  final LearnerProfile profile;

  static const _learningAreas = <(String, String, IconData, AppRoute)>[
    (
      'Grammar',
      'Build clear, correct sentences.',
      Icons.menu_book_outlined,
      AppRoutes.grammar,
    ),
    (
      'Vocabulary',
      'Grow your everyday German words.',
      Icons.menu_book_outlined,
      AppRoutes.vocabulary,
    ),
    (
      'Dictionary',
      'Look up German words.',
      Icons.search,
      AppRoutes.dictionary,
    ),
    (
      'Verbs',
      'Explore forms and conjugations.',
      Icons.compare_arrows,
      AppRoutes.verbs,
    ),
    (
      'Reading',
      'Understand written German.',
      Icons.chrome_reader_mode_outlined,
      AppRoutes.reading,
    ),
    (
      'Listening',
      'Train your listening skills.',
      Icons.headphones_outlined,
      AppRoutes.listening,
    ),
    (
      'Writing',
      'Practise expressing your ideas.',
      Icons.edit_note_outlined,
      AppRoutes.writing,
    ),
    (
      'Speaking',
      'Prepare to speak with confidence.',
      Icons.record_voice_over_outlined,
      AppRoutes.speaking,
    ),
    (
      'Practice',
      'Review what you have learned.',
      Icons.quiz_outlined,
      AppRoutes.practice,
    ),
  ];

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(authRepositoryProvider);
    if (repository == null) return;
    try {
      await repository.signOut();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not sign out. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deutsch Guide'),
        actions: [
          IconButton(
            tooltip: 'Profile settings',
            onPressed: () => context.push(AppRoutes.profile.path),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Hallo, ${profile.displayName}!',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for your next step in German?',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Your current level',
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Chip(label: Text(profile.currentLevel!)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your learning areas are ready. Choose a section to explore.',
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.icon(
                            onPressed: () => context.pushNamed(
                              AppRoutes.courseLevel.name,
                              pathParameters: {
                                'level': profile.currentLevel!.toLowerCase(),
                              },
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label:
                                Text('Continue with ${profile.currentLevel}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Your learning areas', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 3
                        : constraints.maxWidth >= 580
                            ? 2
                            : 1;
                    final spacing = 12.0;
                    final cardWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                            columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final area in _learningAreas)
                          SizedBox(
                            width: cardWidth,
                            child: Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Icon(
                                  area.$3,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                title: Text(area.$1),
                                subtitle: Text(area.$2),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push(area.$4.path),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Learning profile'),
                    subtitle: const Text('Change your name or current level.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(AppRoutes.profile.path),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
