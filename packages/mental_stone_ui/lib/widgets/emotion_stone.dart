import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The signature "emotion stone": a 1:1 crystalline vessel with an organic
/// (squircle) outline, a curved-glass radial highlight, glowing inner blobs
/// and a slow vertical float.
class EmotionStone extends StatefulWidget {
  const EmotionStone({
    super.key,
    this.size = 280,
    this.blobs = const [AppColors.tertiaryFixed, AppColors.secondaryFixed],
    this.float = true,
    this.child,
  });

  final double size;

  /// 1–3 mood colors rendered as soft glowing blobs inside the glass.
  final List<Color> blobs;
  final bool float;
  final Widget? child;

  @override
  State<EmotionStone> createState() => _EmotionStoneState();
}

class _EmotionStoneState extends State<EmotionStone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Organic outline approximating CSS `42% 58% 70% 30% / 45% 45% 55% 55%`.
  BorderRadius _organic(double s) => BorderRadius.only(
        topLeft: Radius.elliptical(s * 0.42, s * 0.45),
        topRight: Radius.elliptical(s * 0.58, s * 0.45),
        bottomRight: Radius.elliptical(s * 0.70, s * 0.55),
        bottomLeft: Radius.elliptical(s * 0.30, s * 0.55),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final radius = _organic(s);

    final stone = ClipRRect(
      borderRadius: radius,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          borderRadius: radius,
          // Curved-glass highlight.
          gradient: const RadialGradient(
            center: Alignment(-0.4, -0.4),
            radius: 1.1,
            colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 40, offset: Offset(0, 20)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < widget.blobs.length; i++)
              Align(
                alignment: i.isEven
                    ? const Alignment(-0.4, -0.6)
                    : const Alignment(0.5, 0.6),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: s * 0.5,
                    height: s * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.blobs[i].withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            // Inner glass sheen.
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
              child: SizedBox(width: s, height: s),
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );

    if (!widget.float) return stone;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -12 * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
      child: stone,
    );
  }
}
