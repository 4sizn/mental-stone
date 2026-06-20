import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mental_stone/app.dart';
import 'package:mental_stone/env.dart';
import 'package:mental_stone_core/mental_stone_core.dart';

/// Pumps for a fixed wall-clock duration. We cannot use pumpAndSettle because
/// the UI has continuous animations (mesh gradient, floating stones).
Future<void> pumpFor(
  WidgetTester tester,
  Duration duration, {
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign up → home → profile → record → analysis walkthrough',
      (tester) async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseKey,
    );
    // Start from a clean, signed-out state.
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}

    await tester.pumpWidget(const ProviderScope(child: MentalStoneApp()));
    await pumpFor(tester, const Duration(seconds: 2));
    await binding.takeScreenshot('01-sign-in');

    // Go to the sign-up screen.
    await tester.tap(find.textContaining('가입하기'));
    await pumpFor(tester, const Duration(seconds: 1));
    await binding.takeScreenshot('02-sign-up');

    // Fill the form (name, email, password).
    final email = 'demo-${DateTime.now().millisecondsSinceEpoch}@example.com';
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '데모 사용자');
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), 'demo-pass-123');
    await pumpFor(tester, const Duration(milliseconds: 600));
    await binding.takeScreenshot('03-sign-up-filled');

    // Submit → email confirm is OFF, so we land on Home.
    await tester.tap(find.text('가입하기'));
    await pumpFor(tester, const Duration(seconds: 6));
    await binding.takeScreenshot('04-home');

    // Open the profile (app-bar menu) → shows the auto-created profile.
    await tester.tap(find.byIcon(Icons.menu));
    await pumpFor(tester, const Duration(seconds: 2));
    await binding.takeScreenshot('05-profile');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await pumpFor(tester, const Duration(seconds: 1));

    // FAB → Record, write an entry.
    await tester.tap(find.byIcon(Icons.add));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.enterText(
        find.byType(TextField).first, '오늘은 마음이 차분하고 맑은 하루였다.');
    await pumpFor(tester, const Duration(milliseconds: 600));
    await binding.takeScreenshot('06-record');

    // Save → persists to Supabase, continues to the analysis screen.
    await tester.tap(find.text('기록 완료'));
    await pumpFor(tester, const Duration(seconds: 6));
    await binding.takeScreenshot('07-analysis');

    // Continue → synthesis (new stone). The button can be below the fold in
    // the scrollable analysis result, so scroll it into view before tapping.
    final synth = find.text('스톤 생성 완료');
    if (synth.evaluate().isNotEmpty) {
      await tester.ensureVisible(synth);
      await pumpFor(tester, const Duration(milliseconds: 500));
      await tester.tap(synth);
      await pumpFor(tester, const Duration(seconds: 3));
      await binding.takeScreenshot('08-synthesis');
    }
  });
}
