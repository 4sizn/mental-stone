import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Small pill chip for moods, percentages and hashtags.
class EmotionChip extends StatelessWidget {
  const EmotionChip({
    super.key,
    required this.label,
    this.color,
    this.tonal = true,
    this.onTap,
    this.selected = false,
  });

  final String label;

  /// Accent color (e.g. AppColors.tertiary). Null = neutral white glass.
  final Color? color;

  /// true = 10% tinted fill + accent text; false = white glass + border.
  final bool tonal;

  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.onSurface;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: tonal
            ? accent.withValues(alpha: selected ? 0.20 : 0.10)
            : Colors.white.withValues(alpha: 0.40),
        borderRadius: AppRadii.rPill,
        border: tonal
            ? (selected ? Border.all(color: accent, width: 1) : null)
            : Border.all(color: AppGlass.edgeStrong, width: 1),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 12,
          letterSpacing: 0,
          color: tonal ? accent : AppColors.onSurface,
        ),
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: chip,
    );
  }
}
