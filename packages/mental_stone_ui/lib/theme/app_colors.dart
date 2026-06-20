import 'package:flutter/material.dart';

/// Ethereal Clarity — raw color tokens (light theme).
///
/// Source of truth: DESIGN.md. Do not invent colors outside this file.
abstract class AppColors {
  // ---- Surfaces ----
  static const surface = Color(0xFFF8F9FF);
  static const surfaceDim = Color(0xFFCBDBF5);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const surfaceVariant = Color(0xFFD3E4FE);

  // ---- Text / outline ----
  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF444748);
  static const outline = Color(0xFF747878);
  static const outlineVariant = Color(0xFFC4C7C8);
  static const surfaceTint = Color(0xFF5D5F5F);

  // ---- Primary ----
  static const primary = Color(0xFF5D5F5F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF747676);
  static const inversePrimary = Color(0xFFC6C6C7);

  // ---- Secondary ----
  static const secondary = Color(0xFF575E72);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFDBE2FA);
  static const onSecondaryContainer = Color(0xFF5D6478);

  // ---- Tertiary ----
  static const tertiary = Color(0xFF765469);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF8F6B81);

  // ---- Error ----
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // ---- Fixed accents ----
  static const primaryFixed = Color(0xFFE2E2E2);
  static const primaryFixedDim = Color(0xFFC6C6C7);
  static const onPrimaryFixed = Color(0xFF1A1C1C);
  static const onPrimaryFixedVariant = Color(0xFF454747);
  static const secondaryFixed = Color(0xFFDBE2FA);
  static const secondaryFixedDim = Color(0xFFBFC6DD);
  static const onSecondaryFixed = Color(0xFF141B2C);
  static const onSecondaryFixedVariant = Color(0xFF3F4759);
  static const tertiaryFixed = Color(0xFFFFD8ED);
  static const tertiaryFixedDim = Color(0xFFE5BAD3);
  static const onTertiaryFixed = Color(0xFF2C1325);
  static const onTertiaryFixedVariant = Color(0xFF5C3D51);

  // ---- Inverse ----
  static const inverseSurface = Color(0xFF213145);
  static const inverseOnSurface = Color(0xFFEAF1FF);

  // ---- Emotion palette (used inside stones / glow bars) ----
  static const moodHappy = Color(0xFFFFD700); // 행복
  static const moodAnticipation = Color(0xFFFF69B4); // 기대
  static const moodSerenity = Color(0xFF22D3EE); // cyan-400
  static const moodClarity = Color(0xFF60A5FA); // blue-400
  static const moodVitality = Color(0xFFC084FC); // purple-400

  /// Material 3 ColorScheme assembled from the tokens above.
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    primaryFixed: primaryFixed,
    primaryFixedDim: primaryFixedDim,
    onPrimaryFixed: onPrimaryFixed,
    onPrimaryFixedVariant: onPrimaryFixedVariant,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    secondaryFixed: secondaryFixed,
    secondaryFixedDim: secondaryFixedDim,
    onSecondaryFixed: onSecondaryFixed,
    onSecondaryFixedVariant: onSecondaryFixedVariant,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    tertiaryFixed: tertiaryFixed,
    tertiaryFixedDim: tertiaryFixedDim,
    onTertiaryFixed: onTertiaryFixed,
    onTertiaryFixedVariant: onTertiaryFixedVariant,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    outline: outline,
    outlineVariant: outlineVariant,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
