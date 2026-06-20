import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

void main() {
  group('design system', () {
    test('color scheme is light', () {
      expect(AppColors.colorScheme.brightness, Brightness.light);
      expect(AppColors.colorScheme.primary, AppColors.primary);
    });

    test('theme uses Hanken Grotesk', () {
      final theme = AppTheme.light();
      expect(theme.textTheme.displayLarge?.fontFamily, 'HankenGrotesk');
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('GlassButton renders its label and fires onPressed',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Center(
              child: GlassButton(
                label: 'Continue',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      expect(tapped, isTrue);
    });

    testWidgets('GlassButton shows a spinner and ignores taps while loading',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Center(
              child: GlassButton(
                label: 'Loading',
                loading: true,
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Loading'));
      expect(tapped, isFalse);
    });
  });
}
