/// A learner's profile as stored in the Supabase `public.profiles` table.
class LearnerProfile {
  const LearnerProfile({
    required this.id,
    required this.displayName,
    required this.currentLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  static const levels = <String>['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  final String id;
  final String displayName;
  final String? currentLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isComplete =>
      displayName.trim().isNotEmpty &&
      currentLevel != null &&
      levels.contains(currentLevel);

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    return LearnerProfile(
      id: json['id'] as String,
      displayName: (json['display_name'] as String? ?? '').trim(),
      currentLevel: (json['current_level'] as String?)?.toUpperCase(),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  static DateTime? _dateTime(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }
}
