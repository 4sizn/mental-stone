import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

enum GlassButtonVariant {
  /// Solid primary — "Store in Vault".
  primary,

  /// High-opacity (60%) frosted glass with 1.5px white border.
  glass,
}

/// Primary action button. [pill] makes it fully rounded (FAB-like CTAs).
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.icon,
    this.pill = false,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final IconData? icon;
  final bool pill;
  final bool expand;

  /// Shows a spinner and disables the button while an async action runs.
  final bool loading;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isGlass = widget.variant == GlassButtonVariant.glass;
    final radius = widget.pill ? AppRadii.rPill : AppRadii.rLg;
    final disabled = widget.onPressed == null || widget.loading;
    final fg = isGlass ? AppColors.onSurface : AppColors.onPrimary;

    final row = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          ),
          const SizedBox(width: AppSpacing.stackSm),
        ],
        Text(
          widget.label,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
        if (widget.icon != null && !widget.loading) ...[
          const SizedBox(width: AppSpacing.stackSm),
          Icon(widget.icon, size: 22, color: fg),
        ],
      ],
    );

    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: row,
    );

    Widget body;
    if (isGlass) {
      // On press the glass "thickens" 60% -> 80%.
      body = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _pressed ? 0.80 : 0.60),
              borderRadius: radius,
              border: Border.all(color: AppGlass.edgeStrong, width: 1.5),
            ),
            child: inner,
          ),
        ),
      );
    } else {
      body = Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: inner,
      );
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: disabled ? null : widget.onPressed,
        child: Opacity(
          opacity: disabled && !widget.loading ? 0.5 : 1,
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: widget.expand ? double.infinity : null,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

/// Round icon-only glass control (e.g. download / share secondary).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: AppGlass.opacityCard),
              border: Border.all(color: AppGlass.edge, width: 1),
            ),
            child: Icon(icon, color: AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}
