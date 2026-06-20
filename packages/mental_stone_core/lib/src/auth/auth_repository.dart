import 'package:supabase_flutter/supabase_flutter.dart';

/// The single seam the app uses for authentication.
///
/// v1 implements email/password. v2 adds native Kakao login by obtaining an
/// OIDC id token from `kakao_flutter_sdk_user` and exchanging it via
/// [GoTrueClient.signInWithIdToken] — the commented [signInWithKakao] below
/// is the intended shape so v2 drops in without reshaping callers.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

  /// Emits the initial session on listen and then on every sign in / sign out
  /// / token refresh. The router subscribes to this to drive redirects.
  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;

  /// Email + password sign up.
  ///
  /// With email confirmation disabled the user is signed in immediately. If a
  /// project still requires confirmation the returned [AuthResponse.session]
  /// is null and the caller should surface a "check your inbox" message.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final name = displayName?.trim();
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: (name == null || name.isEmpty) ? null : {'name': name},
    );
    if (res.session != null) return res;
    // Email confirmation is disabled at the DB level (dev_auto_confirm_email
    // trigger), but GoTrue may still withhold the session on signUp. The user
    // is already confirmed, so sign them in to obtain a session.
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  // ── v2: native Kakao login ─────────────────────────────────────────────
  // Future<AuthResponse> signInWithKakao() async {
  //   // Requires: kakao_flutter_sdk_user, OIDC enabled on the Kakao app,
  //   // `openid` scope, and the Kakao provider enabled in Supabase.
  //   final token = await UserApi.instance.isKakaoTalkInstalled()
  //       ? await UserApi.instance.loginWithKakaoTalk()
  //       : await UserApi.instance.loginWithKakaoAccount();
  //   return _auth.signInWithIdToken(
  //     provider: OAuthProvider.kakao,
  //     idToken: token.idToken!,
  //     accessToken: token.accessToken,
  //   );
  // }
}
