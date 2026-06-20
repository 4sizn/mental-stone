import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_stone_core/mental_stone_core.dart';

import 'app.dart';
import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isConfigured) {
    runApp(const _MisconfiguredApp());
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseKey,
  );

  runApp(const ProviderScope(child: MentalStoneApp()));
}

/// Shown when the app is launched without Supabase env values, so the failure
/// is obvious instead of a cryptic crash.
class _MisconfiguredApp extends StatelessWidget {
  const _MisconfiguredApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.settings_suggest, size: 48),
                SizedBox(height: 16),
                Text(
                  'Supabase 설정이 없습니다.\n\n'
                  'apps/mobile/env.json 을 만든 뒤\n'
                  '--dart-define-from-file=env.json 으로 실행하세요.\n'
                  '(env.example.json 참고)',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
