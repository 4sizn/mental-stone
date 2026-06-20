import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-bleed shifting pastel mesh gradient (Level 1 background).
/// Place at the bottom of a [Stack] behind glass surfaces.
class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key, this.animate = false});

  /// When true the focal points drift slowly.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.surface,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: animate ? const _AnimatedMesh() : const _StaticMesh(),
        ),
      ),
    );
  }
}

class _StaticMesh extends StatelessWidget {
  const _StaticMesh();
  @override
  Widget build(BuildContext context) => const _MeshPoints(t: 0);
}

class _AnimatedMesh extends StatefulWidget {
  const _AnimatedMesh();
  @override
  State<_AnimatedMesh> createState() => _AnimatedMeshState();
}

class _AnimatedMeshState extends State<_AnimatedMesh>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) => _MeshPoints(t: _c.value),
      );
}

class _MeshPoints extends StatelessWidget {
  const _MeshPoints({required this.t});
  final double t; // 0..1

  @override
  Widget build(BuildContext context) {
    final dx = 0.4 * (0.5 - (t - 0.5).abs()); // gentle drift
    return Stack(
      children: [
        _blob(const Alignment(-1, -1), const Color(0x66D3E4FE), dx),
        _blob(const Alignment(1, -1), const Color(0x66FFD8ED), -dx),
        _blob(const Alignment(1, 1), const Color(0x66EFF4FF), dx),
        _blob(const Alignment(-1, 1), const Color(0x66DBE2FA), -dx),
      ],
    );
  }

  Widget _blob(Alignment a, Color c, double shift) => Align(
        alignment: Alignment(a.x + shift, a.y),
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [c, c.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      );
}
