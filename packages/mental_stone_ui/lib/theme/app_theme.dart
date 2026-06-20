import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Assembles the Ethereal Clarity [ThemeData] (Material 3, light).
abstract class AppTheme {
  static ThemeData light() {
    final scheme = AppColors.colorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: AppTextStyles.textTheme,
      splashFactory: InkSparkle.splashFactory,
      // The console/marketing palette uses transparent app bars; real
      // surfaces are the glass widgets in lib/widgets.
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.onSurface,
        centerTitle: true,
      ),
      iconTheme: const IconThemeData(color: AppColors.onSurface, weight: 300),
    );
  }
}
