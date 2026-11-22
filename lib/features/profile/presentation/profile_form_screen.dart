import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../domain/learner_profile.dart';
import '../providers/profile_providers.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({
    required this.isOnboarding,
    super.key,
  });

  final bool isOnboarding;

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String _selectedLevel = 'A1';
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(learnerProfileProvider).valueOrNull;
    final repository = ref.read(profileRepositoryProvider);
    _nameController = TextEditingController(
      text: profile?.displayName ?? repository?.suggestedDisplayName ?? '',
    );
    _selectedLevel = profile?.currentLevel ?? 'A1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = ref.read(profileRepositoryProvider);
    if (repository == null) {
      setState(() => _errorMessage = 'Profile service is not configured.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await repository.saveCurrentProfile(
        displayName: _nameController.text,
        currentLevel: _selectedLevel,
      );
      ref.invalidate(learnerProfileProvider);
      if (mounted) context.go(AppRoutes.dashboard.path);
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Your profile could not be saved. Check your connection and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(learnerProfileProvider);

    return profileState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(widget.isOnboarding ? 'Set up your profile' : 'Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your profile could not be loaded.'),
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
      data: (_) => _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isOnboarding ? 'Set up your profile' : 'Your profile',
        ),
        automaticallyImplyLeading: !widget.isOnboarding,
        leading: widget.isOnboarding
            ? null
            : IconButton(
                tooltip: 'Back to dashboard',
                onPressed: () => context.go(AppRoutes.dashboard.path),
                icon: const Icon(Icons.arrow_back),
              ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 44,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.isOnboarding
                              ? 'Let’s personalise your learning'
                              : 'Learning preferences',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isOnboarding
                              ? 'Choose the name and starting level for your German journey.'
                              : 'Update your name or the CEFR level you are currently studying.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 80,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.isEmpty) return 'Enter your name.';
                            if (name.length > 80) {
                              return 'Use 80 characters or fewer.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLevel,
                          decoration: const InputDecoration(
                            labelText: 'Current German level',
                            prefixIcon: Icon(Icons.stairs_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final level in LearnerProfile.levels)
                              DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ),
                          ],
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _selectedLevel = value);
                                  }
                                },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _saveProfile,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            _isSaving
                                ? 'Saving…'
                                : widget.isOnboarding
                                    ? 'Start learning'
                                    : 'Save changes',
                          ),
                        ),
                      ],
                    ),
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
