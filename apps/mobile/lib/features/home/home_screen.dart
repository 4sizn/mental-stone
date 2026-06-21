import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';

/// Screen 01 — Home / My Journey. The "TODAY'S STATE" stone is decorative;
/// "Recent Records" is backed by the user's real journal entries.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.showBottomNav = true});

  /// Set false when hosted inside [MainShell] (which owns the nav).
  final bool showBottomNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final profile = ref.watch(myProfileProvider).valueOrNull;

    final recent = entriesAsync.when<List<Widget>>(
      loading: () => const [
        Padding(
          padding: EdgeInsets.only(top: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (_, _) => [const _MessageCard('기록을 불러오지 못했어요.')],
      data: (entries) => entries.isEmpty
          ? [const _EmptyRecords()]
          : [
              for (final e in entries.take(6))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                  child: _EntryCard(entry: e),
                ),
            ],
    );

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
          const EtherealBackground(variant: AuraVariant.home),
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.marginPage,
              MediaQuery.paddingOf(context).top + 52,
              AppSpacing.marginPage,
              150,
            ),
            children: [
              const _DateStrip(),
              const SizedBox(height: AppSpacing.stackLg),
              Center(
                child: EmotionStone(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "TODAY'S STATE",
                        style: AppTextStyles.labelMedium.copyWith(
                          letterSpacing: 1.6,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Balanced', style: AppTextStyles.displayLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.stackMd),
              const _StoneCaption(),
              const SizedBox(height: AppSpacing.stackLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Recent Records', style: AppTextStyles.headlineMedium),
                  Text(
                    'View All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryFixedDim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.stackMd),
              ...recent,
            ],
          ),
          if (showBottomNav)
            const Align(
              alignment: Alignment.bottomCenter,
              child: GlassBottomNav(active: NavItem.home),
            ),
        ],
      ),
    );
  }
}

String _formatWhen(DateTime dt) {
  final now = DateTime.now();
  final d = now.difference(dt);
  if (d.inMinutes < 1) return '방금';
  if (d.inMinutes < 60) return '${d.inMinutes}분 전';
  if (d.inHours < 24) return '${d.inHours}시간 전';
  if (d.inDays < 7) return '${d.inDays}일 전';
  return '${dt.month}월 ${dt.day}일';
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final title = (entry.mood?.trim().isNotEmpty ?? false)
        ? entry.mood!.trim()
        : '오늘의 기록';
    final body = entry.body?.trim() ?? '';
    return GlassCard(
      borderRadius: AppRadii.rXl,
      onTap: () => context.push(Routes.diary, extra: entry),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed.withValues(alpha: 0.35),
              borderRadius: AppRadii.rXl,
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.tertiary,
              size: 26,
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
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatWhen(entry.createdAt),
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const Icon(
            Icons.spa_outlined,
            color: AppColors.onSurfaceVariant,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            '아직 기록이 없어요',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            '+ 버튼을 눌러 첫 감정을 기록해 보세요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      GlassCard(child: Text(text, style: AppTextStyles.bodyMedium));
}

class _StoneCaption extends StatelessWidget {
  const _StoneCaption();
  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.bodyMedium;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text.rich(
          TextSpan(
            text: 'Your stone is glowing with a mixture of ',
            style: base,
            children: [
              TextSpan(
                text: 'Hope',
                style: base.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: ' and ', style: base),
              TextSpan(
                text: 'Calm',
                style: base.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: '.', style: base),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip();
  final _days = const [
    ('Mon', '12', false),
    ('Tue', '13', false),
    ('Wed', '14', true),
    ('Thu', '15', false),
    ('Fri', '16', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.gutter),
        itemBuilder: (_, i) {
          final (dow, num, active) = _days[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: AppRadii.rXxl,
              border: active
                  ? null
                  : Border.all(color: AppGlass.edge, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dow,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: active ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  num,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: active ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
