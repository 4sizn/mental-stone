import 'package:supabase_flutter/supabase_flutter.dart';

/// Runs [action]; if it fails with an authentication error, refreshes the
/// session once and retries.
///
/// The access token can expire while the app sits in the background: the
/// auto-refresh timer is paused, so the first write after resume may go out
/// with a stale JWT and come back 401 before the on-resume refresh lands. That
/// surfaced to users as a spurious "저장에 실패했어요" on edit/save. Refreshing and
/// retrying once closes that race. Non-auth errors propagate unchanged so real
/// failures (validation, connectivity, RLS denials) still reach the caller.
Future<T> runWithFreshSession<T>(
  GoTrueClient auth,
  Future<T> Function() action,
) async {
  try {
    return await action();
  } on AuthException {
    await auth.refreshSession();
    return await action();
  } on PostgrestException catch (e) {
    if (!_isAuthError(e)) rethrow;
    await auth.refreshSession();
    return await action();
  }
}

/// Whether a PostgREST error reflects an expired/invalid token rather than a
/// genuine data problem.
bool _isAuthError(PostgrestException e) {
  if (e.code == '401' || e.code == 'PGRST301') return true;
  final msg = e.message.toLowerCase();
  return msg.contains('jwt') || msg.contains('token');
}
