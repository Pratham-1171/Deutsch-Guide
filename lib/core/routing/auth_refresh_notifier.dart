import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bridges Supabase's auth stream to GoRouter's refreshListenable.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(SupabaseClient client) {
    _subscription = client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.passwordRecovery) {
        isPasswordRecovery = true;
      } else if (state.event == AuthChangeEvent.signedOut ||
          state.event == AuthChangeEvent.userUpdated) {
        isPasswordRecovery = false;
      }
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  bool isPasswordRecovery = false;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
