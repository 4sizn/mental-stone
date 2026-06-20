import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import 'package:mental_stone/features/auth/sign_in_screen.dart';

void main() {
  // Renders without Supabase: SignInScreen only touches the repository when
  // the user submits, which this test does not do.
  testWidgets('SignInScreen renders email/password fields and CTA',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SignInScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.textContaining('가입하기'), findsOneWidget);
  });

  testWidgets('SignInScreen shows a validation error for a bad email',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SignInScreen(),
        ),
      ),
    );
    await tester.pump();

    // Tap 로그인 without entering anything.
    await tester.tap(find.text('로그인'));
    await tester.pump();

    expect(find.text('올바른 이메일을 입력해 주세요.'), findsOneWidget);
  });
}
