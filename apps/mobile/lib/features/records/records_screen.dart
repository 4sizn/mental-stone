import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';

/// Screen 06 — My Stone Records (the "jewelry box" collection).
///
/// v1 keeps the designed visualization as a showcase; wiring the calendar to
/// real aggregates is a follow-up.
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key, this.showBottomNav = true});

  /// Set false when hosted inside [MainShell] (which owns the nav).
  final bool showBottomNav;
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  int _tab = 1; // 주 / 월 / 연

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(
        onLeading: () => context.push(Routes.profile),
      ),
      body: Stack(
        children: [
          const MeshBackground(),
          ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage, 96, AppSpacing.marginPage, 120),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Collection', style: AppTextStyles.labelMedium),
                      Text('6월 누적 기록',
                          style: AppTextStyles.headlineLargeMobile),
                    ],
                  ),
                  Row(children: [
                    _round(Icons.chevron_left),
                    const SizedBox(width: AppSpacing.stackSm),
                    _round(Icons.chevron_right),
                  ]),
                ],
              ),
              const SizedBox(height: AppSpacing.stackMd),
              _segmented(),
              const SizedBox(height: AppSpacing.stackLg),
              GlassCard(
                borderRadius: AppRadii.rCard,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppSpacing.gutter,
                      crossAxisSpacing: AppSpacing.gutter,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        _Label('S'), _Label('M'), _Label('T'), _Label('W'),
                        _StoneCell(day: '01', color: AppColors.tertiary),
                        _StoneCell(day: '02', color: AppColors.secondary),
                        _StoneCell(day: '03'), // empty
                        _StoneCell(day: '04', color: AppColors.primary),
                        _StoneCell(day: '05'),
                        _StoneCell(day: '06', color: AppColors.tertiaryFixedDim),
                        _StoneCell(day: '07', color: AppColors.secondaryFixedDim),
                        _StoneCell(day: '08', color: AppColors.outline),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    const Divider(color: Color(0x33FFFFFF), height: 1),
                    const SizedBox(height: AppSpacing.stackMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('이번 달 총 22개의 감정 수집',
                            style: AppTextStyles.labelMedium),
                        SizedBox(
                          width: 56,
                          height: 24,
                          child: Stack(children: const [
                            Positioned(left: 0, child: _Dot(AppColors.tertiary)),
                            Positioned(left: 16, child: _Dot(AppColors.secondary)),
                            Positioned(left: 32, child: _Dot(AppColors.primary)),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text('최근 일기 요약', style: AppTextStyles.labelMedium),
              const SizedBox(height: AppSpacing.stackMd),
              _summary('6월 7일 금요일', '오후 11:30',
                  '오늘은 유난히 차분한 하루였다. 복잡했던 생각들이 저녁 노을과 함께 가라앉는 기분이었다.',
                  AppColors.tertiary, AppColors.tertiaryFixed,
                  const ['#차분함', '#사색']),
              const SizedBox(height: AppSpacing.stackMd),
              _summary('6월 6일 목요일', '오후 10:15',
                  '프로젝트 결과가 좋아서 정말 기뻤던 날. 친구들과 맛있는 저녁을 먹으며 에너지를 얻었다.',
                  AppColors.secondary, AppColors.secondaryFixed,
                  const ['#활기찬', '#성취감']),
              const SizedBox(height: AppSpacing.stackMd),
              _summary('6월 4일 화요일', '오전 08:20',
                  '조금은 몽롱한 아침. 어제 읽다 만 소설의 여운이 가시지 않아 침대에서 조금 더 뒹굴거렸다.',
                  AppColors.primary, AppColors.surfaceVariant,
                  const ['#몽상', '#평온']),
            ],
          ),
          if (widget.showBottomNav)
            const Align(
              alignment: Alignment.bottomCenter,
              child: GlassBottomNav(active: NavItem.records),
            ),
        ],
      ),
    );
  }

  Widget _round(IconData icon) => GlassCard(
        padding: const EdgeInsets.all(8),
        borderRadius: AppRadii.rPill,
        child: Icon(icon, color: AppColors.onSurface, size: 20),
      );

  Widget _segmented() {
    const labels = ['주', '월', '연'];
    return GlassCard(
      padding: const EdgeInsets.all(4),
      borderRadius: AppRadii.rPill,
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.transparent,
                    borderRadius: AppRadii.rPill,
                  ),
                  child: Text(labels[i],
                      style: AppTextStyles.labelMedium.copyWith(
                          letterSpacing: 0,
                          fontWeight:
                              _tab == i ? FontWeight.w700 : FontWeight.w500,
                          color: _tab == i
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summary(String date, String time, String body, Color accent,
      Color tint, List<String> tags) {
    return GlassCard(
      borderRadius: AppRadii.rXl,
      onTap: () => context.push(Routes.diary),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.elliptical(26, 26),
                topRight: Radius.elliptical(38, 26),
                bottomRight: Radius.elliptical(45, 38),
                bottomLeft: Radius.elliptical(19, 38),
              ),
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.9)),
            ),
          ),
          const SizedBox(width: AppSpacing.gutter),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date,
                        style: AppTextStyles.labelMedium.copyWith(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface)),
                    Text(time,
                        style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12, letterSpacing: 0)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.stackSm),
                Row(
                  children: [
                    for (final t in tags) ...[
                      EmotionChip(label: t, tonal: false),
                      const SizedBox(width: AppSpacing.stackSm),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Opacity(
          opacity: 0.5,
          child: Text(text, style: AppTextStyles.labelMedium),
        ),
      );
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      );
}

/// A single collected (or empty) day stone in the grid.
class _StoneCell extends StatelessWidget {
  const _StoneCell({required this.day, this.color});
  final String day;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.only(
      topLeft: Radius.elliptical(40, 40),
      topRight: Radius.elliptical(60, 50),
      bottomRight: Radius.elliptical(70, 60),
      bottomLeft: Radius.elliptical(30, 50),
    );
    final empty = color == null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: radius,
                color: empty ? null : color!.withValues(alpha: 0.18),
                border: Border.all(
                  color: empty
                      ? Colors.white.withValues(alpha: 0.5)
                      : color!.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: empty
                  ? Icon(Icons.question_mark,
                      size: 18,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5))
                  : FractionallySizedBox(
                      widthFactor: 0.6,
                      heightFactor: 0.6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color!.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(day,
            style: AppTextStyles.labelMedium
                .copyWith(fontSize: 10, letterSpacing: 0)),
      ],
    );
  }
}
