import 'package:deutsch_guide/features/profile/domain/learner_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearnerProfile', () {
    test('maps a complete profile and normalises the CEFR level', () {
      final profile = LearnerProfile.fromJson({
        'id': 'user-123',
        'display_name': 'Alex',
        'current_level': 'b2',
        'created_at': '2026-11-22T10:00:00.000Z',
        'updated_at': '2026-11-22T10:30:00.000Z',
      });

      expect(profile.id, 'user-123');
      expect(profile.displayName, 'Alex');
      expect(profile.currentLevel, 'B2');
      expect(profile.isComplete, isTrue);
      expect(profile.createdAt, isNotNull);
      expect(profile.updatedAt, isNotNull);
    });

    test('an unselected or unsupported level needs onboarding', () {
      final incomplete = LearnerProfile.fromJson({
        'id': 'user-456',
        'display_name': 'Sam',
        'current_level': null,
      });
      final unsupported = LearnerProfile.fromJson({
        'id': 'user-789',
        'display_name': 'Taylor',
        'current_level': 'C3',
      });

      expect(incomplete.isComplete, isFalse);
      expect(unsupported.isComplete, isFalse);
    });

    test('an empty display name is incomplete', () {
      const profile = LearnerProfile(
        id: 'user-000',
        displayName: '   ',
        currentLevel: 'A1',
        createdAt: null,
        updatedAt: null,
      );

      expect(profile.isComplete, isFalse);
    });
  });
}
