import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';

/// Screen 04 — Emotion Analysis. Runs a ~4s "analysis" progress, then reveals
/// the result card. (Real AI analysis is out of v1 scope.)
class EmotionAnalysisScreen extends StatefulWidget {
  const EmotionAnalysisScreen({super.key});
  @override
  State<EmotionAnalysisScreen> createState() => _EmotionAnalysisScreenState();
}

class _EmotionAnalysisScreenState extends State<EmotionAnalysisScreen> {
  double _progress = 0;
  bool _done = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    const step = 40; // ms
    const total = 4000;
    _timer = Timer.periodic(const Duration(milliseconds: step), (t) {
      setState(() {
        _progress += step / total;
        if (_progress >= 1) {
          _progress = 1;
          _done = true;
          t.cancel();
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
          const MeshBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage,
                96,
                AppSpacing.marginPage,
                120,
              ),
              child: Column(
                children: [
                  _AnalysisStone(charged: _done),
                  const SizedBox(height: AppSpacing.stackLg),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _done ? _result() : _analyzing(),
                  ),
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
      key: const ValueKey('analyzing'),
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

  Widget _result() {
    return Column(
      key: const ValueKey('result'),
      children: [
        GlassCard(
          borderRadius: AppRadii.rXxl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '분석 결과',
                    style: AppTextStyles.headlineLargeMobile.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text('오늘의 돌 조각', style: AppTextStyles.labelMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.stackMd),
              const GlowBar(
                label: '행복',
                value: 0.60,
                color: AppColors.moodClarity,
              ),
              const SizedBox(height: AppSpacing.stackMd),
              const GlowBar(
                label: '기대',
                value: 0.25,
                color: AppColors.moodVitality,
              ),
              const SizedBox(height: AppSpacing.stackMd),
              const GlowBar(label: '불안', value: 0.15, color: Colors.white),
              const SizedBox(height: AppSpacing.stackMd),
              Text(
                '"오늘 당신의 마음은 맑은 하늘 아래 살랑이는 바람 같습니다. '
                '작은 기대가 행복을 더 선명하게 만들고 있네요."',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.stackLg),
        GlassButton(
          label: '스톤 생성 완료',
          variant: GlassButtonVariant.glass,
          pill: true,
          onPressed: () => context.push(Routes.synthesis),
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
