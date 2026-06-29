import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';
import '../../widgets/journal_summary_card.dart';

/// Calendar tab — a real month calendar of the user's journal entries.
/// Swipe left/right (or tap the chevrons) to change month; tap a recorded day
/// to open that day's detail.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month;
  double _dragDx = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  Future<void> _pickMonth() async {
    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) =>
          _MonthYearPickerDialog(selected: _month, now: DateTime.now()),
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final entriesAsync = ref.watch(journalEntriesProvider);
    final topPad = MediaQuery.paddingOf(context).top + 52;

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
          entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Text('기록을 불러오지 못했어요.', style: AppTextStyles.bodyMedium),
            ),
            data: (entries) {
              final monthEntries = entries.where((e) {
                final d = e.createdAt.toLocal();
                return d.year == _month.year && d.month == _month.month;
              }).toList();

              // day → that day's entries (newest first, as the provider sorts).
              final entriesByDay = <int, List<JournalEntry>>{};
              for (final e in monthEntries) {
                final day = e.createdAt.toLocal().day;
                (entriesByDay[day] ??= <JournalEntry>[]).add(e);
              }

              return GestureDetector(
                // Swipe right → previous month, swipe left → next month.
                // Decide by flick velocity OR total drag distance, so both a
                // quick flick and a slow drag flip the month.
                onHorizontalDragStart: (_) => _dragDx = 0,
                onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
                onHorizontalDragEnd: (details) {
                  final v = details.primaryVelocity ?? 0;
                  if (v > 250 || _dragDx > 60) {
                    _changeMonth(-1);
                  } else if (v < -250 || _dragDx < -60) {
                    _changeMonth(1);
                  }
                },
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.marginPage,
                    topPad,
                    AppSpacing.marginPage,
                    120,
                  ),
                  children: [
                    Text('My Calendar', style: AppTextStyles.labelMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _pickMonth,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_month.year}년 ${_month.month}월',
                                style: AppTextStyles.headlineLargeMobile,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.expand_more,
                                color: AppColors.onSurface,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _roundGlassButton(
                              Icons.chevron_left,
                              () => _changeMonth(-1),
                            ),
                            const SizedBox(width: AppSpacing.stackSm),
                            _roundGlassButton(
                              Icons.chevron_right,
                              () => _changeMonth(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    _MonthGrid(
                      year: _month.year,
                      month: _month.month,
                      entriesByDay: entriesByDay,
                      onOpen: (entry) =>
                          context.push(Routes.diary, extra: entry),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                    Text(
                      '${_month.month}월 기록',
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    if (monthEntries.isEmpty)
                      const _EmptyMonth()
                    else
                      for (var i = 0; i < monthEntries.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.stackMd,
                          ),
                          child: JournalSummaryCard(
                            entry: monthEntries[i],
                            accent: kEntryAccents[i % kEntryAccents.length],
                            tint: kEntryTints[i % kEntryTints.length],
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}

/// Small round glass control (month chevrons, year nav). A null [onTap] dims
/// the button and makes it inert.
Widget _roundGlassButton(IconData icon, VoidCallback? onTap) => Opacity(
  opacity: onTap == null ? 0.35 : 1,
  child: GlassCard(
    onTap: onTap,
    padding: const EdgeInsets.all(8),
    borderRadius: AppRadii.rPill,
    child: Icon(icon, color: AppColors.onSurface, size: 20),
  ),
);

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.year,
    required this.month,
    required this.entriesByDay,
    required this.onOpen,
  });

  final int year;
  final int month;
  final Map<int, List<JournalEntry>> entriesByDay;
  final void Function(JournalEntry entry) onOpen;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // weekday: 1=Mon..7=Sun → S-first grid offset (Sun=0).
    final leadBlanks = DateTime(year, month, 1).weekday % 7;
    final count = entriesByDay.values.fold<int>(0, (s, l) => s + l.length);
    // One stone per day that has a record (matches the colored day cells);
    // a day with several records still shows a single stone.
    final stones = entriesByDay.length;

    final cells = <Widget>[
      for (var i = 0; i < leadBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(
          day: day,
          dayEntries: entriesByDay[day],
          accent: kEntryAccents[day % kEntryAccents.length],
          onOpen: onOpen,
        ),
    ];

    return GlassCard(
      borderRadius: AppRadii.rCard,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              for (final w in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSm),
          // Explicit week rows (instead of GridView) so the header→days gap
          // and row height are predictable; cells stay ~square so day stones
          // remain round.
          for (var start = 0; start < cells.length; start += 7)
            Padding(
              padding: EdgeInsets.only(top: start == 0 ? 0 : 6),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: SizedBox(
                          height: 40,
                          child: start + col < cells.length
                              ? cells[start + col]
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.stackMd),
          const Divider(color: Color(0x33FFFFFF), height: 1),
          const SizedBox(height: AppSpacing.stackMd),
          _StatRow(label: '이번달 감정 기록', value: '$count개'),
          const SizedBox(height: AppSpacing.stackSm),
          _StatRow(label: '이번달 스톤 수집', value: '$stones개'),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dayEntries,
    required this.accent,
    required this.onOpen,
  });

  final int day;
  final List<JournalEntry>? dayEntries;
  final Color accent;
  final void Function(JournalEntry entry) onOpen;

  @override
  Widget build(BuildContext context) {
    final entries = dayEntries;
    final hasEntry = entries != null && entries.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Recorded days open that day's entry; empty days stay inert.
      onTap: hasEntry ? () => onOpen(entries.first) : null,
      child: Container(
        alignment: Alignment.center,
        decoration: hasEntry
            ? BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(16, 16),
                  topRight: Radius.elliptical(22, 18),
                  bottomRight: Radius.elliptical(24, 20),
                  bottomLeft: Radius.elliptical(12, 18),
                ),
                color: accent.withValues(alpha: 0.18),
                border: Border.all(color: accent.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ],
              )
            : null,
        child: Center(
          child: Text(
            '$day',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 11,
              letterSpacing: 0,
              fontWeight: hasEntry ? FontWeight.w700 : FontWeight.w500,
              color: hasEntry
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// One summary line under the calendar grid: a left label and a right value.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Year + month picker shown when the calendar header is tapped. Years are
/// navigable with the chevrons (no future years); a month chip tap confirms
/// and pops the chosen [DateTime]. Future months in the current year are
/// disabled so a user can never land on an upcoming month.
class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({required this.selected, required this.now});

  final DateTime selected;
  final DateTime now;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year = widget.selected.year;

  @override
  Widget build(BuildContext context) {
    final now = widget.now;
    final canGoNextYear = _year < now.year;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: GlassCard(
        modal: true,
        borderRadius: AppRadii.rCard,
        padding: const EdgeInsets.all(AppSpacing.glassPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year navigation.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundGlassButton(
                  Icons.chevron_left,
                  () => setState(() => _year--),
                ),
                Text('$_year년', style: AppTextStyles.headlineMedium),
                _roundGlassButton(
                  Icons.chevron_right,
                  canGoNextYear ? () => setState(() => _year++) : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.stackMd),
            // Month grid — 4 columns × 3 rows.
            for (var row = 0; row < 3; row++)
              Padding(
                padding: EdgeInsets.only(top: row == 0 ? 0 : AppSpacing.stackSm),
                child: Row(
                  children: [
                    for (var col = 0; col < 4; col++)
                      Expanded(child: _monthChip(row * 4 + col + 1)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _monthChip(int month) {
    final now = widget.now;
    final isFuture = _year == now.year && month > now.month;
    final isSelected =
        _year == widget.selected.year && month == widget.selected.month;

    final chip = Center(
      child: EmotionChip(
        label: '$month월',
        color: AppColors.primary,
        selected: isSelected,
        onTap: isFuture
            ? null
            : () => Navigator.of(context).pop(DateTime(_year, month)),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      child: isFuture ? Opacity(opacity: 0.35, child: chip) : chip,
    );
  }
}

class _EmptyMonth extends StatelessWidget {
  const _EmptyMonth();
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.onSurfaceVariant,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text('이 달의 기록이 없어요', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
