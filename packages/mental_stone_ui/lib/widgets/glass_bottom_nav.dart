import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

enum NavItem { home, calendar, records }

/// Floating frosted-glass pill navigation (Level 3 — 60px blur @ 40%).
/// The active destination tints primary, scales up and fills its icon.
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.active,
    this.onChanged,
  });

  final NavItem active;
  final ValueChanged<NavItem>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: ClipRRect(
            borderRadius: AppRadii.rPill,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.4),
                  borderRadius: AppRadii.rPill,
                  border: Border.all(color: AppGlass.edge, width: 1),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x261F2687),
                        blurRadius: 32,
                        offset: Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavCell(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        on: active == NavItem.home,
                        onTap: () => onChanged?.call(NavItem.home)),
                    _NavCell(
                        icon: Icons.calendar_today,
                        label: 'Calendar',
                        on: active == NavItem.calendar,
                        onTap: () => onChanged?.call(NavItem.calendar)),
                    _NavCell(
                        icon: Icons.history_edu,
                        label: 'Records',
                        on: active == NavItem.records,
                        onTap: () => onChanged?.call(NavItem.records)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = on ? AppColors.primary : AppColors.onSurfaceVariant;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        scale: on ? 1.1 : 1,
        duration: const Duration(milliseconds: 200),
        child: Opacity(
          opacity: on ? 1 : 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: color, letterSpacing: 0)),
            ],
          ),
        ),
      ),
    );
  }
}
