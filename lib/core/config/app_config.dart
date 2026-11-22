/// Public build-time configuration, supplied with --dart-define.
///
/// Example:
///   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
///              --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
///
/// Only the public anon key belongs here. Never put a service-role key or any
/// other private secret in the app.
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get isProduction => environment == 'prod';
}
