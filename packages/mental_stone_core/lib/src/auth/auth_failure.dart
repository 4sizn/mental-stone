import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps a raw auth error to a user-facing Korean message.
///
/// Kept free of Flutter imports so it is trivially unit-testable.
String authErrorMessage(Object error) {
  if (_looksLikeNetworkError(error)) {
    return '인터넷 연결을 확인해 주세요.';
  }
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already exists')) {
      return '이미 가입된 이메일입니다.';
    }
    if (msg.contains('password should be at least')) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    if (msg.contains('unable to validate email') ||
        msg.contains('invalid email') ||
        msg.contains('invalid format')) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    if (msg.contains('email not confirmed')) {
      return '이메일 확인이 필요합니다. 받은 편지함을 확인해 주세요.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return '요청이 많습니다. 잠시 후 다시 시도해 주세요.';
    }
    return error.message;
  }
  return '문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
}

/// Detects connectivity failures (no network, DNS failure, connection refused)
/// without importing `package:http`/`dart:io`, so this stays Flutter-free.
///
/// Covers `ClientException` (package:http), `SocketException` (dart:io), and
/// Supabase's retryable fetch wrapper, by matching on the error's type name
/// and message text.
bool _looksLikeNetworkError(Object error) {
  if (error is AuthRetryableFetchException) return true;
  final text = error.toString().toLowerCase();
  return text.contains('clientexception') ||
      text.contains('socketexception') ||
      text.contains('failed host lookup') ||
      text.contains('connection refused') ||
      text.contains('connection closed') ||
      text.contains('network is unreachable') ||
      text.contains('connection timed out') ||
      text.contains('software caused connection abort');
}
