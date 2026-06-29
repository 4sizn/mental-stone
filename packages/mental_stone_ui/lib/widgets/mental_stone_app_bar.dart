import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Header-less top controls (no glass bar, no title). Renders only small
/// floating buttons over the content: a back button on detail screens, or a
/// profile avatar on the main screens. Used as a [Scaffold.appBar] with
/// `extendBodyBehindAppBar: true` so content fills the screen behind it.
class MentalStoneAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MentalStoneAppBar({
    super.key,
    this.title = 'Mental Stone',
    this.subtitle,
    this.back = false,
    this.onLeading,
    this.avatarUrl,
    this.onAvatarTap,
    this.actions,
  });

  // Kept for API compatibility with the previous bar; no longer rendered.
  final String title;
  final String? subtitle;

  final bool back;
  final VoidCallback? onLeading;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  /// Trailing controls shown on the right (e.g. edit / delete on detail
  /// screens). Rendered after the spacer, alongside the back button.
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final showAvatar =
        !back && (avatarUrl != null || onAvatarTap != null || onLeading != null);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 4, AppSpacing.gutter, 0),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              if (back)
                _GlassCircle(
                  icon: Icons.arrow_back,
                  onTap: onLeading,
                  semanticLabel: 'Back',
                )
              else
                const SizedBox(width: 40),
              const Spacer(),
              if (showAvatar)
                _AvatarButton(url: avatarUrl, onTap: onAvatarTap ?? onLeading),
              if (actions != null)
                for (final action in actions!) ...[
                  const SizedBox(width: 8),
                  action,
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.28),
                border: Border.all(color: AppGlass.edge, width: 1),
              ),
              child: Icon(icon, color: AppColors.onSurface, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({this.url, this.onTap});
  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Profile',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondaryContainer,
            border: Border.all(color: AppGlass.edgeStrong, width: 1.5),
            image: url != null
                ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
                : null,
            boxShadow: const [
              BoxShadow(
                  color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: url == null
              ? const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.onSecondaryContainer,
                )
              : null,
        ),
      ),
    );
  }
}
