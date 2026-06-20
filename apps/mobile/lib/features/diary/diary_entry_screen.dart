import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

/// Screen 02 — Diary Entry (read view). v1 shows a designed sample entry.
class DiaryEntryScreen extends StatelessWidget {
  const DiaryEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(
        back: true,
        subtitle: 'Diary Entry',
        onLeading: () => context.pop(),
      ),
      body: Stack(
        children: [
          const MeshBackground(),
          ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage, 104, AppSpacing.marginPage, 40),
            children: [
              const Center(child: _HeroStone()),
              const SizedBox(height: AppSpacing.stackMd),
              Center(
                child: Column(
                  children: [
                    const EmotionChip(
                        label: 'Calm & Reflective',
                        color: AppColors.secondary),
                    const SizedBox(height: AppSpacing.stackSm),
                    Text('The Silence of Morning',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLargeMobile),
                    Text('Monday, October 14 • 7:30 AM',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: Color(0x335D5F5F), width: 4)),
                      ),
                      child: Text(
                        '"I woke up before the alarm today. The light was '
                        'filtering through the curtains in a way that felt '
                        'like a quiet conversation..."',
                        style: AppTextStyles.bodyLarge.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.onSurface),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Text(
                      "There's a specific kind of clarity that comes with "
                      'early morning silence. Today, the world felt less like '
                      'a series of tasks and more like a space for being.\n\n'
                      'The weight of yesterday\'s stress seemed to have '
                      'dissipated during sleep, leaving behind a smooth, cool '
                      'surface of calm.',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Wrap(
                      spacing: AppSpacing.stackSm,
                      runSpacing: AppSpacing.stackSm,
                      children: const [
                        EmotionChip(label: '#MorningRoutine', tonal: false),
                        EmotionChip(label: '#Gratitude', tonal: false),
                        EmotionChip(label: '#Clarity', tonal: false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.analytics, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Emotional Spectrum',
                              style: AppTextStyles.headlineMedium),
                        ]),
                        Text('AI Analysis', style: AppTextStyles.labelMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    const GlowBar(
                        label: 'Serenity',
                        value: 0.85,
                        color: AppColors.moodSerenity),
                    const SizedBox(height: AppSpacing.stackMd),
                    const GlowBar(
                        label: 'Clarity',
                        value: 0.72,
                        color: AppColors.moodClarity),
                    const SizedBox(height: AppSpacing.stackMd),
                    const GlowBar(
                        label: 'Vitality',
                        value: 0.45,
                        color: AppColors.moodVitality),
                    const SizedBox(height: AppSpacing.stackMd),
                    Text(
                      '"Your entry suggests a high state of mindful presence '
                      'and a significant reduction in cortisol markers."',
                      style: AppTextStyles.labelMedium.copyWith(
                          fontStyle: FontStyle.italic, letterSpacing: 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Share Insight',
                      variant: GlassButtonVariant.glass,
                      expand: true,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.stackMd),
                  Expanded(
                    child: GlassButton(
                      label: 'Store in Vault',
                      expand: true,
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStone extends StatefulWidget {
  const _HeroStone();
  @override
  State<_HeroStone> createState() => _HeroStoneState();
}

class _HeroStoneState extends State<_HeroStone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
          offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
          child: child),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: AppGlass.edge, width: 1),
              gradient: const RadialGradient(
                center: Alignment(-0.4, -0.4),
                colors: [Color(0x4DFFFFFF), Color(0x1AFFFFFF)],
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x4DBADBF5), blurRadius: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
