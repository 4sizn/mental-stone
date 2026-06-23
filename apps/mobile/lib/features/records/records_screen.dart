import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';
import 'records_providers.dart';

/// Screen 06 — My Stone Collection.
///
/// A sectioned overview. The "감정 스톤" section is a 4-column collection grid
/// of all emotions (count per collected stone; tap → that emotion's records).
/// Other sub-sections can stack below it.
class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key, this.showBottomNav = true});

  /// Set false when hosted inside [MainShell] (which owns the nav).
  final bool showBottomNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final counts = ref.watch(emotionCountsProvider);
    final collected = counts.values.where((c) => c > 0).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(
        avatarUrl: profile?.avatarUrl,
        onLeading: () => context.push(Routes.profile),
        onAvatarTap: () => context.push(Routes.profile),
      ),
      body: Stack(
        children: [
          const EtherealBackground(variant: AuraVariant.records),
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.marginPage,
              MediaQuery.paddingOf(context).top + 52,
              AppSpacing.marginPage,
              120,
            ),
            children: [
              Text('My Collection', style: AppTextStyles.labelMedium),
              Text('Records', style: AppTextStyles.headlineLargeMobile),
              const SizedBox(height: AppSpacing.stackLg),

              // ── Section: 감정 스톤 (4-column collection grid) ──
              _SectionHeader(
                title: '감정 스톤',
                trailing: '$collected / ${Emotion.values.length} 수집',
              ),
              const SizedBox(height: AppSpacing.stackSm),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.stackSm,
                crossAxisSpacing: AppSpacing.stackSm,
                childAspectRatio: 0.82,
                children: [
                  for (final e in Emotion.values)
                    _StoneCell(emotion: e, count: counts[e] ?? 0),
                ],
              ),

              // Future sub-sections stack here (e.g. 최근 기록, 통계 …).
            ],
          ),
          if (showBottomNav)
            const Align(
              alignment: Alignment.bottomCenter,
              child: GlassBottomNav(active: NavItem.records),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primaryFixedDim,
            ),
          ),
      ],
    );
  }
}

/// One stone in the collection grid. Collected stones are full-color and
/// tappable; not-yet-collected ones are dimmed and inert.
class _StoneCell extends StatelessWidget {
  const _StoneCell({required this.emotion, required this.count});
  final Emotion emotion;
  final int count;

  @override
  Widget build(BuildContext context) {
    final collected = count > 0;
    final cell = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StoneBadge(color: emotion.color, size: 48),
        const SizedBox(height: 6),
        Text(
          emotion.nameKo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          collected ? '$count회' : '미수집',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 10,
            letterSpacing: 0,
            color: collected
                ? AppColors.primary
                : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: collected
          ? () => context.push(Routes.recordsByEmotion, extra: emotion)
          : null,
      child: Opacity(opacity: collected ? 1 : 0.4, child: cell),
    );
  }
}

/// A lightweight, static colored stone (placeholder for the final PNG asset).
class StoneBadge extends StatelessWidget {
  const StoneBadge({super.key, required this.color, this.size = 56});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.only(
      topLeft: Radius.elliptical(40, 40),
      topRight: Radius.elliptical(60, 50),
      bottomRight: Radius.elliptical(70, 60),
      bottomLeft: Radius.elliptical(30, 50),
    );
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: color.withValues(alpha: 0.22),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: FractionallySizedBox(
        widthFactor: 0.55,
        heightFactor: 0.55,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.9),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10),
            ],
          ),
        ),
      ),
    );
  }
}
