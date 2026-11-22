import 'package:material_ui/material_ui.dart';

import '../../../../core/config/app_config.dart';

class AuthPageFrame extends StatelessWidget {
  const AuthPageFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded,
                          size: 42, color: theme.colorScheme.primary),
                      const SizedBox(height: 18),
                      Text('Deutsch Guide',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 22),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      if (!AppConfig.hasSupabase) ...[
                        const Text(
                          'Authentication is not configured yet. Run the app '
                          'with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY '
                          'build-time values to enable account access.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ] else
                        child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
