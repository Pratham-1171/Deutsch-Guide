import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/learner_profile.dart';

/// Reads and updates only the currently authenticated learner's profile.
class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  String get suggestedDisplayName {
    final user = _client.auth.currentUser;
    final metadataName = user?.userMetadata?['display_name'];
    if (metadataName is String && metadataName.trim().isNotEmpty) {
      return metadataName.trim();
    }

    final email = user?.email ?? '';
    final localPart = email.split('@').first.trim();
    return localPart.isEmpty ? 'Learner' : localPart;
  }

  Future<LearnerProfile?> loadCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (row == null) return null;
    return LearnerProfile.fromJson(row);
  }

  Future<LearnerProfile> saveCurrentProfile({
    required String displayName,
    required String currentLevel,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in again to update your profile.');
    }

    final cleanName = displayName.trim();
    if (cleanName.isEmpty || cleanName.length > 80) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'Name must contain between 1 and 80 characters.',
      );
    }
    if (!LearnerProfile.levels.contains(currentLevel)) {
      throw ArgumentError.value(
        currentLevel,
        'currentLevel',
        'Choose a valid CEFR level.',
      );
    }

    final row = await _client
        .from('profiles')
        .update({
          'display_name': cleanName,
          'current_level': currentLevel,
        })
        .eq('id', user.id)
        .select()
        .single();

    return LearnerProfile.fromJson(row);
  }
}
