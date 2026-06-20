import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';

/// Screen 05 — Emotion Synthesis (a new stone is born).
class EmotionSynthesisScreen extends StatelessWidget {
  const EmotionSynthesisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(back: true, onLeading: () => context.pop()),
      body: Stack(
        children: [
          const MeshBackground(animate: true),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage,
                80,
                AppSpacing.marginPage,
                120,
              ),
              child: Column(
                children: [
                  Text(
                    'EMOTION SYNTHESIS COMPLETE',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  Text(
                    '새로운 감정 스톤 탄생',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  Text(
                    '행복의 따스함과 기대의 설렘이 응축된\n고유한 조각이 완성되었습니다.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  const _SynthesisStone(),
                  const SizedBox(height: AppSpacing.stackLg),
                  Row(
                    children: [
                      Expanded(
                        child: _statTile('행복', '64%', AppColors.moodHappy),
                      ),
                      const SizedBox(width: AppSpacing.stackMd),
                      Expanded(
                        child: _statTile(
                          '기대',
                          '36%',
                          AppColors.moodAnticipation,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  GlassButton(
                    label: '도감에 보관하기',
                    icon: Icons.auto_awesome,
                    variant: GlassButtonVariant.glass,
                    pill: true,
                    expand: true,
                    onPressed: () => context.go(Routes.home),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: '공유하기',
                          icon: Icons.share,
                          variant: GlassButtonVariant.glass,
                          pill: true,
                          expand: true,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.stackMd),
                      _RoundGlass(icon: Icons.download, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return GlassCard(
      borderRadius: AppRadii.rLg,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.rPill,
              boxShadow: [BoxShadow(color: color, blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundGlass extends StatelessWidget {
  const _RoundGlass({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: AppGlass.edge, width: 1),
            ),
            child: Icon(icon, color: AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}

/// The morphing, golden-pink-cored synthesis stone.
class _SynthesisStone extends StatefulWidget {
  const _SynthesisStone();
  @override
  State<_SynthesisStone> createState() => _SynthesisStoneState();
}

class _SynthesisStoneState extends State<_SynthesisStone>
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

  @override
  Widget build(BuildContext context) {
    const s = 260.0;
    final radius = BorderRadius.only(
      topLeft: Radius.elliptical(s * 0.42, s * 0.45),
      topRight: Radius.elliptical(s * 0.58, s * 0.45),
      bottomRight: Radius.elliptical(s * 0.70, s * 0.55),
      bottomLeft: Radius.elliptical(s * 0.30, s * 0.55),
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return Transform.translate(
          offset: Offset(0, -12 * t),
          child: SizedBox(
            width: s,
            height: s,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: s * 0.6 * (1 + 0.15 * t),
                    height: s * 0.6 * (1 + 0.15 * t),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.moodHappy,
                          AppColors.moodAnticipation,
                        ],
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: AppGlass.edgeStrong,
                          width: 1.5,
                        ),
                        gradient: const RadialGradient(
                          center: Alignment(-0.4, -0.4),
                          colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
