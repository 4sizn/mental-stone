import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';

/// Screen 04 — Emotion Analysis. Runs a ~4s "AI 분석 중" progress, then
/// advances straight to the synthesis result (which presents the final stone),
/// so the analysis step is a transition rather than a duplicate result screen.
/// (Real AI analysis is out of v1 scope.)
class EmotionAnalysisScreen extends StatefulWidget {
  const EmotionAnalysisScreen({super.key});
  @override
  State<EmotionAnalysisScreen> createState() => _EmotionAnalysisScreenState();
}

class _EmotionAnalysisScreenState extends State<EmotionAnalysisScreen> {
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    const step = 40; // ms
    const total = 4000;
    _timer = Timer.periodic(const Duration(milliseconds: step), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _progress += step / total;
        if (_progress >= 1) {
          _progress = 1;
          t.cancel();
          // The loader is a transition, not a destination: replace it so back
          // from synthesis doesn't land on a finished progress bar.
          context.pushReplacement(Routes.synthesis);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(back: true, onLeading: () => context.pop()),
      body: Stack(
        children: [
          const EtherealBackground(variant: AuraVariant.analysis),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.marginPage,
                MediaQuery.paddingOf(context).top + 52,
                AppSpacing.marginPage,
                120,
              ),
              child: Column(
                children: [
                  _AnalysisStone(charged: _progress >= 1),
                  const SizedBox(height: AppSpacing.stackLg),
                  _analyzing(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyzing() {
    return Column(
      children: [
        Text(
          'AI 감정 분석 중 (${(_progress * 100).round()}%)',
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.stackMd),
        ClipRRect(
          borderRadius: AppRadii.rPill,
          child: Container(
            height: 4,
            color: Colors.white.withValues(alpha: 0.2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _progress,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.white, blurRadius: 10),
                      BoxShadow(color: Colors.white, blurRadius: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          '문장의 온도를 측정하고 있습니다...',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _AnalysisStone extends StatefulWidget {
  const _AnalysisStone({required this.charged});
  final bool charged;
  @override
  State<_AnalysisStone> createState() => _AnalysisStoneState();
}

class _AnalysisStoneState extends State<_AnalysisStone>
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
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Transform.translate(
        offset: Offset(0, -12 * Curves.easeInOut.transform(_c.value)),
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.4, -0.4),
              colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.charged
                    ? AppColors.moodClarity.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.5),
                blurRadius: widget.charged ? 60 : 40,
                spreadRadius: widget.charged ? 4 : 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              _blob(const Alignment(-0.6, -0.6), AppColors.moodClarity, 110),
              _blob(const Alignment(0.6, 0.6), const Color(0xFFDDD6FE), 130),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(Alignment a, Color c, double size) => Align(
    alignment: a,
    child: ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withValues(alpha: 0.7),
        ),
      ),
    ),
  );
}
