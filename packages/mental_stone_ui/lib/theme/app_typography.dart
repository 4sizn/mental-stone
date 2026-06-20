import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Hanken Grotesk type scale. letterSpacing is in logical px
/// (em × fontSize): e.g. -0.02em × 48 = -0.96.
abstract class AppTextStyles {
  static const String fontFamily = 'HankenGrotesk';

  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    height: 56 / 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.96,
    color: AppColors.onSurface,
  );

  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
    color: AppColors.onSurface,
  );

  /// Mobile headline used on detail screens (28px).
  static const headlineLargeMobile = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.28,
    color: AppColors.onSurfaceVariant,
  );

  /// Maps the scale onto a Material [TextTheme].
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: headlineLargeMobile,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelMedium: labelMedium,
  );
}
