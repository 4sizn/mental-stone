import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_dimens.dart';

/// A frosted glass surface — the base primitive of the system.
///
/// Level 2 (default) = 40px blur @ 20% white with a 30% white edge.
/// Pass [modal] true for Level 3 (60px blur @ 40%).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.glassPadding),
    this.borderRadius = AppRadii.rCard,
    this.modal = false,
    this.opacity,
    this.blur,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool modal;
  final double? opacity;
  final double? blur;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fill = (opacity ?? (modal ? AppGlass.opacityModal : AppGlass.opacityCard));
    final b = blur ?? (modal ? AppGlass.blurModal : AppGlass.blurCard);

    Widget content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: b / 2, sigmaY: b / 2),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: fill),
            borderRadius: borderRadius,
            border: border ?? Border.all(color: AppGlass.edge, width: 1),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = _PressScale(onTap: onTap!, child: content);
    }
    return content;
  }
}

/// Subtle active:scale(0.98) press feedback used across the app.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  double _scale = 1;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}
