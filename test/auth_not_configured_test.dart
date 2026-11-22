import 'package:deutsch_guide/features/auth/presentation/sign_in_screen.dart';
import 'package:deutsch_guide/features/auth/presentation/sign_up_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _unconfiguredMessage =
    'Account access is not configured in this build. Please install the '
    'correctly configured app build.';

void main() {
  testWidgets('sign-in explains when account access is unavailable',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignInScreen()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text(_unconfiguredMessage), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('sign-up explains when account access is unavailable',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignUpScreen()),
      ),
    );

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text(_unconfiguredMessage), findsOneWidget);
    expect(find.text('Create account'), findsNothing);
  });
}
