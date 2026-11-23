import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/curriculum.dart';

class CurriculumRepository {
  const CurriculumRepository();

  Future<Curriculum> loadLevel(String level) async {
    final normalised = level.toLowerCase();
    if (normalised != 'a1') {
      throw UnsupportedError('The $level curriculum is not available yet.');
    }
    final source = await rootBundle.loadString(
      'assets/curriculum/v1/a1.json',
    );
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Curriculum root must be an object.');
    }
    return Curriculum.fromJson(decoded);
  }
}

final curriculumRepositoryProvider = Provider<CurriculumRepository>(
  (ref) => const CurriculumRepository(),
);

final curriculumProvider =
    FutureProvider.family<Curriculum, String>((ref, level) {
  return ref.watch(curriculumRepositoryProvider).loadLevel(level);
});
