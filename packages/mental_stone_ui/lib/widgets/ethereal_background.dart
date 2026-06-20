import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Per-screen Level-1 backgrounds, matching the Mental Stone design frames
/// (Mental Stone.dc.html). Each is a [Positioned.fill] — drop it as the first
/// child of a screen [Stack].
enum AuraVariant {
  /// Home / Diary — diagonal pastel linear gradient.
  home,

  /// Record — linear gradient + two large floating blurred blobs.
  record,

  /// Analysis — solid surface; the glowing stone provides the color.
  analysis,

  /// Synthesis — four-corner radial wash, blurred 80.
  synthesis,

  /// Records — softer four-corner radial wash, blurred 100.
  records,
}

class EtherealBackground extends StatelessWidget {
  const EtherealBackground({super.key, this.variant = AuraVariant.home});

  final AuraVariant variant;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AuraVariant.analysis:
        return const Positioned.fill(
          child: ColoredBox(color: AppColors.surface),
        );
      case AuraVariant.home:
        return const Positioned.fill(child: _LinearAura());
      case AuraVariant.record:
        return const Positioned.fill(child: _RecordAura());
      case AuraVariant.synthesis:
        return const Positioned.fill(child: _CornerAura(blur: 80, alpha: 1.0));
      case AuraVariant.records:
        return const Positioned.fill(child: _CornerAura(blur: 100, alpha: 0.4));
    }
  }
}

/// `linear-gradient(135deg,#f8f9ff 0%,#e5eeff 50%,#eff4ff 100%)`
class _LinearAura extends StatelessWidget {
  const _LinearAura();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface, // #f8f9ff
          AppColors.surfaceContainer, // #e5eeff
          AppColors.surfaceContainerLow, // #eff4ff
        ],
        stops: [0, 0.5, 1],
      ),
    ),
  );
}

class _RecordAura extends StatelessWidget {
  const _RecordAura();
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: _LinearAura()),
      _blob(const Alignment(-1.1, -1.1), 384, const Color(0xFFD3E4FE)),
      _blob(const Alignment(1.05, 0.9), 320, const Color(0xFFE5BAD3)),
    ],
  );

  Widget _blob(Alignment a, double size, Color color) => Align(
    alignment: a,
    child: ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.5),
        ),
      ),
    ),
  );
}

/// Four soft radial focal points (one per corner) over the surface, then a big
/// blur — the "mesh gradient" look from the Synthesis / Records frames.
class _CornerAura extends StatelessWidget {
  const _CornerAura({required this.blur, required this.alpha});
  final double blur;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Stack(
          children: [
            _corner(Alignment.topLeft, const Color(0xFFD3E4FE)),
            _corner(Alignment.topRight, const Color(0xFFFFD8ED)),
            _corner(Alignment.bottomRight, const Color(0xFFEFF4FF)),
            _corner(Alignment.bottomLeft, const Color(0xFFDBE2FA)),
          ],
        ),
      ),
    );
  }

  Widget _corner(Alignment a, Color c) => Align(
    alignment: a,
    child: FractionallySizedBox(
      widthFactor: 0.85,
      heightFactor: 0.85,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              c.withValues(alpha: alpha),
              c.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    ),
  );
}
