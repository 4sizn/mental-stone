import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Slim frosted top bar. Sits over content (use with
/// `extendBodyBehindAppBar: true`). Compact by design — a light glass wash, a
/// small title and 40/36px touch targets — so it doesn't dominate the screen.
class MentalStoneAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MentalStoneAppBar({
    super.key,
    this.title = 'Mental Stone',
    this.subtitle,
    this.back = false,
    this.onLeading,
    this.avatarUrl,
    this.onAvatarTap,
  });

  final String title;
  final String? subtitle;
  final bool back;
  final VoidCallback? onLeading;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 56 : 68);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 4, AppSpacing.gutter, 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.18),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: subtitle == null ? 40 : 48,
              child: Row(
                children: [
                  _IconSlot(
                    icon: back ? Icons.arrow_back : Icons.menu,
                    onTap: onLeading,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 20,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppColors.primary,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 12,
                              height: 1.1,
                              letterSpacing: 0,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _Avatar(url: avatarUrl, onTap: onAvatarTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconSlot extends StatelessWidget {
  const _IconSlot({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: AppColors.onSurface, size: 24),
          ),
        ),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.onTap});
  final String? url;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Profile',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer,
              border: Border.all(color: AppGlass.edge, width: 1.5),
              image: url != null
                  ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
                  : null,
            ),
            child: url == null
                ? const Icon(
                    Icons.person,
                    size: 18,
                    color: AppColors.onSecondaryContainer,
                  )
                : null,
          ),
        ),
      );
}
