import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The signature "emotion stone": a 1:1 crystalline vessel whose organic
/// outline slowly **morphs** (CSS `@keyframes morph`, 12s), with a curved-glass
/// radial highlight and glowing inner blobs.
class EmotionStone extends StatefulWidget {
  const EmotionStone({
    super.key,
    this.size = 280,
    this.blobs = const [AppColors.tertiaryFixed, AppColors.secondaryFixed],
    this.float = false,
    this.child,
  });

  final double size;

  /// 1–3 mood colors rendered as soft glowing blobs inside the glass.
  final List<Color> blobs;

  /// Adds a gentle vertical float on top of the morph.
  final bool float;
  final Widget? child;

  @override
  State<EmotionStone> createState() => _EmotionStoneState();
}

class _EmotionStoneState extends State<EmotionStone>
    with SingleTickerProviderStateMixin {
  // 6s each direction → a 12s morph cycle, matching the design.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // morph 0%  : 42% 58% 70% 30% / 45% 45% 55% 55%
  BorderRadius _r0(double s) => BorderRadius.only(
    topLeft: Radius.elliptical(s * 0.42, s * 0.45),
    topRight: Radius.elliptical(s * 0.58, s * 0.45),
    bottomRight: Radius.elliptical(s * 0.70, s * 0.55),
    bottomLeft: Radius.elliptical(s * 0.30, s * 0.55),
  );

  // morph 50% : 70% 30% 46% 54% / 30% 74% 26% 70%
  BorderRadius _r1(double s) => BorderRadius.only(
    topLeft: Radius.elliptical(s * 0.70, s * 0.30),
    topRight: Radius.elliptical(s * 0.30, s * 0.74),
    bottomRight: Radius.elliptical(s * 0.46, s * 0.26),
    bottomLeft: Radius.elliptical(s * 0.54, s * 0.70),
  );

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        final radius = BorderRadius.lerp(_r0(s), _r1(s), t)!;
        final dy = widget.float ? -12 * t : 0.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: _stone(s, radius),
        );
      },
    );
  }

  Widget _stone(double s, BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const RadialGradient(
            center: Alignment(-0.4, -0.4),
            radius: 1.1,
            colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
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
                  imageFilter: ImageFilter.blur(
                    sigmaX: s * 0.1,
                    sigmaY: s * 0.1,
                  ),
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
            // Inner glass sheen (approximates the inset highlight).
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
  }
}
