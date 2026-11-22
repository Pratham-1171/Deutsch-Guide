import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routing/app_routes.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_page_frame.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _destination() {
    final candidate = GoRouterState.of(context).uri.queryParameters['next'];
    if (candidate == null || !candidate.startsWith('/') ||
        candidate.startsWith('//')) {
      return AppRoutes.dashboard.path;
    }
    final uri = Uri.tryParse(candidate);
    if (uri == null || uri.hasScheme || uri.hasAuthority) {
      return AppRoutes.dashboard.path;
    }
    return candidate;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = ref.read(authRepositoryProvider);
    if (repository == null) return;
    final destination = _destination();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await repository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) context.go(destination);
    } on AuthException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      title: 'Welcome back',
      subtitle: 'Sign in to continue learning German.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty || !email.contains('@')) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _signIn(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Enter your password.' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.forgotPassword.path),
                child: const Text('Forgot password?'),
              ),
            ),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _isLoading ? null : _signIn,
              child: Text(_isLoading ? 'Signing in…' : 'Sign in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.signUp.path),
              child: const Text('New here? Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
