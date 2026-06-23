import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';
import '../../widgets/journal_summary_card.dart';

/// Screen 06 — My Stone Records (the "jewelry box" collection).
///
/// The month grid, the collected-count, and the summary list are all driven by
/// the signed-in user's real entries for the current month.
class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key, this.showBottomNav = true});

  /// Set false when hosted inside [MainShell] (which owns the nav).
  final bool showBottomNav;
  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  int _tab = 1; // 주 / 월 / 연

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final entries =
        ref.watch(journalEntriesProvider).valueOrNull ?? const <JournalEntry>[];

    // This month's entries (newest first, as delivered by the provider).
    final monthEntries = entries.where((e) {
      final d = e.createdAt.toLocal();
      return d.year == now.year && d.month == now.month;
    }).toList();

    // Days that have at least one entry → drives the filled stones.
    final entryDays = <int>{
      for (final e in monthEntries) e.createdAt.toLocal().day,
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(onLeading: () => context.push(Routes.profile)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Collection', style: AppTextStyles.labelMedium),
                      Text(
                        '${now.month}월 누적 기록',
                        style: AppTextStyles.headlineLargeMobile,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _round(Icons.chevron_left),
                      const SizedBox(width: AppSpacing.stackSm),
                      _round(Icons.chevron_right),
                    ],
                  ),
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
                    _MonthStoneGrid(
                      year: now.year,
                      month: now.month,
                      entryDays: entryDays,
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    const Divider(color: Color(0x33FFFFFF), height: 1),
                    const SizedBox(height: AppSpacing.stackMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '이번 달 총 ${monthEntries.length}개의 감정 수집',
                          style: AppTextStyles.labelMedium,
                        ),
                        SizedBox(
                          width: 56,
                          height: 24,
                          child: Stack(
                            children: const [
                              Positioned(
                                left: 0,
                                child: _Dot(AppColors.tertiary),
                              ),
                              Positioned(
                                left: 16,
                                child: _Dot(AppColors.secondary),
                              ),
                              Positioned(
                                left: 32,
                                child: _Dot(AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text('최근 일기 요약', style: AppTextStyles.labelMedium),
              const SizedBox(height: AppSpacing.stackMd),
              if (monthEntries.isEmpty)
                const _EmptyRecords()
              else
                for (var i = 0; i < monthEntries.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                    child: JournalSummaryCard(
                      entry: monthEntries[i],
                      accent: kEntryAccents[i % kEntryAccents.length],
                      tint: kEntryTints[i % kEntryTints.length],
                    ),
                  ),
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
                  child: Text(
                    labels[i],
                    style: AppTextStyles.labelMedium.copyWith(
                      letterSpacing: 0,
                      fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w500,
                      color: _tab == i
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A real current-month grid of collected stones. Filled cells are days with at
/// least one entry; the rest render as empty placeholders.
class _MonthStoneGrid extends StatelessWidget {
  const _MonthStoneGrid({
    required this.year,
    required this.month,
    required this.entryDays,
  });

  final int year;
  final int month;
  final Set<int> entryDays;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // weekday: 1=Mon..7=Sun → S-first grid offset (Sun=0).
    final leadBlanks = DateTime(year, month, 1).weekday % 7;

    final cells = <Widget>[
      for (var i = 0; i < leadBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _StoneCell(
          day: day,
          color: entryDays.contains(day)
              ? kEntryAccents[day % kEntryAccents.length]
              : null,
        ),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final w in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(child: _Label(w)),
          ],
        ),
        const SizedBox(height: AppSpacing.stackSm),
        GridView.count(
          crossAxisCount: 7,
          mainAxisSpacing: AppSpacing.gutter,
          crossAxisSpacing: AppSpacing.gutter,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
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
  final int day;
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
                  ? const SizedBox.shrink()
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
        Text(
          day.toString().padLeft(2, '0'),
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 10,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

/// Shown when the current month has no recorded entries yet.
class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();
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
          Text('이번 달 수집한 감정 스톤이 아직 없어요', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
