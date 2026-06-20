import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Shared frosted top app bar. Leading shows a [back] arrow or a menu.
/// Implements [PreferredSizeWidget] so it drops into [Scaffold.appBar].
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
  Size get preferredSize => Size.fromHeight(subtitle == null ? 72 : 84);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.marginPage,
            14,
            AppSpacing.marginPage,
            14,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.2),
            border: const Border(
              bottom: BorderSide(color: AppGlass.edge, width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 30,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                _LeadingButton(
                  icon: back ? Icons.arrow_back : Icons.menu,
                  onTap: onLeading,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTextStyles.labelMedium.copyWith(
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
    );
  }
}

class _LeadingButton extends StatelessWidget {
  const _LeadingButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onTap,
    radius: 26,
    child: SizedBox(
      width: 48,
      height: 48,
      child: Icon(icon, color: AppColors.onSurface),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.onTap});
  final String? url;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondaryContainer,
        border: Border.all(color: AppGlass.edge, width: 2),
        image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      child: url == null
          ? const Icon(
              Icons.person,
              size: 20,
              color: AppColors.onSecondaryContainer,
            )
          : null,
    ),
  );
}
