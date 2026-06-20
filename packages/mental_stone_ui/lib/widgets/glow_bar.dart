import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// "Glow line" progress bar used by the AI emotion analysis.
/// A thin track with a neon outer glow in [color].
class GlowBar extends StatelessWidget {
  const GlowBar({
    super.key,
    required this.label,
    required this.value, // 0..1
    required this.color,
    this.trailingPercent = true,
    this.animate = true,
  });

  final String label;
  final double value;
  final Color color;
  final bool trailingPercent;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurface,
                letterSpacing: 0,
              ),
            ),
            if (trailingPercent)
              Text(
                '${(value * 100).round()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppRadii.rPill,
          child: Container(
            height: 8,
            color: Colors.white.withValues(alpha: 0.25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth * value.clamp(0, 1);
                  final bar = Container(
                    height: 8,
                    width: w,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.7),
                      borderRadius: AppRadii.rPill,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.7),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  );
                  if (!animate) return bar;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: w),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (_, animW, _) =>
                        SizedBox(width: animW, child: bar),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
