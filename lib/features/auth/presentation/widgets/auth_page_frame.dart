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
    final colors = theme.colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.72),
              theme.scaffoldBackgroundColor,
              colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.22),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 38,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'DEUTSCH GUIDE',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Card(
                      elevation: 2,
                      shadowColor: colors.shadow.withValues(alpha: 0.10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (!AppConfig.hasSupabase) ...[
                              const Icon(Icons.cloud_off_outlined, size: 32),
                              const SizedBox(height: 12),
                              const Text(
                                'Account access is not configured in this build. Please install the correctly configured app build.',
                                textAlign: TextAlign.center,
                              ),
                            ] else
                              child,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Learn at your pace · A1 to C2',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
