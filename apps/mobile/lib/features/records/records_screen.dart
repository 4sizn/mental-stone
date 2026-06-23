import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';
import 'records_providers.dart';

/// Screen 06 — My Stone Collection.
///
/// A sectioned overview. The "감정 스톤" section is a compact horizontal rail
/// (counts per emotion; tap → that emotion's records). It deliberately stays
/// shallow so future sub-sections can stack below it.
class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key, this.showBottomNav = true});

  /// Set false when hosted inside [MainShell] (which owns the nav).
  final bool showBottomNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final stones = ref.watch(emotionStoneCountsProvider);

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

              // ── Section: 감정 스톤 (compact horizontal rail) ──
              _SectionHeader(title: '감정 스톤', trailing: '${stones.length}종 수집'),
              const SizedBox(height: AppSpacing.stackMd),
              if (stones.isEmpty)
                const _EmptyStones()
              else
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: stones.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.stackMd),
                    itemBuilder: (_, i) => _StoneTile(stone: stones[i]),
                  ),
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

/// Compact tile in the horizontal stone rail.
class _StoneTile extends StatelessWidget {
  const _StoneTile({required this.stone});
  final EmotionStoneCount stone;

  @override
  Widget build(BuildContext context) {
    final e = stone.emotion;
    return SizedBox(
      width: 92,
      child: GlassCard(
        borderRadius: AppRadii.rXl,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        onTap: () => context.push(Routes.recordsByEmotion, extra: e),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StoneBadge(color: e.color, size: 48),
            const SizedBox(height: 8),
            Text(
              e.nameKo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${stone.count}회',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 11,
                letterSpacing: 0,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
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

class _EmptyStones extends StatelessWidget {
  const _EmptyStones();
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.onSurfaceVariant,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text('아직 수집한 감정 스톤이 없어요', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
