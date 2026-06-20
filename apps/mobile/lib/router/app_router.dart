import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';

import '../features/analysis/emotion_analysis_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/diary/diary_entry_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/record/record_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/synthesis/emotion_synthesis_screen.dart';

/// Route paths in one place so screens don't hardcode strings.
abstract class Routes {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const home = '/';
  static const record = '/record';
  static const analysis = '/analysis';
  static const synthesis = '/synthesis';
  static const diary = '/diary';
  static const profile = '/profile';

  static const _public = {signIn, signUp};
  static bool isPublic(String location) => _public.contains(location);
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final refresh = _GoRouterRefreshStream(authRepo.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = authRepo.currentSession != null;
      final atAuth = Routes.isPublic(state.matchedLocation);
      if (!signedIn && !atAuth) return Routes.signIn;
      if (signedIn && atAuth) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
          path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
          path: Routes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: Routes.home, builder: (_, _) => const MainShell()),
      GoRoute(
          path: Routes.record, builder: (_, _) => const RecordScreen()),
      GoRoute(
          path: Routes.analysis,
          builder: (_, _) => const EmotionAnalysisScreen()),
      GoRoute(
          path: Routes.synthesis,
          builder: (_, _) => const EmotionSynthesisScreen()),
      GoRoute(
          path: Routes.diary, builder: (_, _) => const DiaryEntryScreen()),
      GoRoute(
          path: Routes.profile, builder: (_, _) => const ProfileScreen()),
    ],
  );
});

/// Bridges an auth [Stream] to a [Listenable] so GoRouter re-evaluates its
/// redirect on every sign in / sign out.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
