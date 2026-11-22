/// Public build-time configuration, supplied with --dart-define.
///
/// Example:
///   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co
///              --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
///
/// Publishable keys are intended for client applications. Never put a
/// Supabase secret or service-role key in the app.
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const String environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
  static bool get isProduction => environment == 'prod';
}
