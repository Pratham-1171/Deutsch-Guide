/// Compile-time switches for features that are not ready for every build.
class FeatureFlags {
  const FeatureFlags._();

  static const bool teacherWorkspace =
      bool.fromEnvironment('FF_TEACHER', defaultValue: true);
  static const bool speaking =
      bool.fromEnvironment('FF_SPEAKING', defaultValue: false);
}
