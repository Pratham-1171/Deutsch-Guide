import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routing/app_routes.dart';
import '../providers/auth_providers.dart';
import 'widgets/auth_page_frame.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _requestSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = ref.read(authRepositoryProvider);
    if (repository == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await repository.sendPasswordReset(_emailController.text);
      if (mounted) setState(() => _requestSent = true);
    } on AuthException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to send the reset request. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      title: _requestSent ? 'Check your inbox' : 'Reset your password',
      subtitle: _requestSent
          ? 'If an account exists for this address, a password reset link has been sent.'
          : 'Enter the email address linked to your account.',
      child: _requestSent
          ? FilledButton(
              onPressed: () => context.go(AppRoutes.signIn.path),
              child: const Text('Back to sign in'),
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) => _sendResetLink(),
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
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    child: Text(_isLoading ? 'Sending…' : 'Send reset link'),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signIn.path),
                    child: const Text('Back to sign in'),
                  ),
                ],
              ),
            ),
    );
  }
}
