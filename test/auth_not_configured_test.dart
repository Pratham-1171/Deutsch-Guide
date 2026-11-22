import 'package:deutsch_guide/features/auth/presentation/sign_in_screen.dart';
import 'package:deutsch_guide/features/auth/presentation/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign-in explains how to enable Supabase when unconfigured',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignInScreen()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Authentication is not configured yet. Run the app '
        'with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY build-time values '
        'to enable account access.'), findsOneWidget);
  });

  testWidgets('sign-up explains how to enable Supabase when unconfigured',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignUpScreen()),
      ),
    );

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Authentication is not configured yet. Run the app '
        'with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY build-time values '
        'to enable account access.'), findsOneWidget);
  });
}
