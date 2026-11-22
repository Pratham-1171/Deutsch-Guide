import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../data/auth_repository.dart';

/// Null when the app is running in its intentional no-backend demo mode.
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return AuthRepository(Supabase.instance.client);
});
