import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/profile_repository.dart';
import '../domain/learner_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ProfileRepository(Supabase.instance.client);
});

/// Emits auth changes so profile data is reloaded after sign-in or sign-out.
final profileAuthChangesProvider = StreamProvider<AuthState>((ref) {
  if (!AppConfig.hasSupabase) return const Stream<AuthState>.empty();
  return Supabase.instance.client.auth.onAuthStateChange;
});

final learnerProfileProvider = FutureProvider<LearnerProfile?>((ref) async {
  ref.watch(profileAuthChangesProvider);
  final repository = ref.watch(profileRepositoryProvider);
  return repository?.loadCurrentProfile();
});
