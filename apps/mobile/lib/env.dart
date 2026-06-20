/// Compile-time configuration, injected with
/// `--dart-define-from-file=env.json` (see env.example.json).
abstract class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase publishable (or legacy anon) key for the client.
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY');

  /// v2 — native Kakao login.
  static const String kakaoNativeAppKey =
      String.fromEnvironment('KAKAO_NATIVE_APP_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
