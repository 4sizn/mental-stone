import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

/// Drives the sign-in / sign-up forms.
///
/// State is `AsyncValue<void>`: loading while a request is in flight, error
/// (carrying the original [AuthException]) on failure, and data(null) when
/// idle or succeeded. Navigation is NOT done here — the router reacts to the
/// resulting session change.
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email.trim(), password: password);
    });
    return !state.hasError;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            email: email.trim(),
            password: password,
            displayName: displayName,
          );
    });
    return !state.hasError;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);
