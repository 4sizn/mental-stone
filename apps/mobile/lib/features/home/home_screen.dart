import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';
import '../../widgets/journal_summary_card.dart';

/// Screen 01 — Home / My Journey. The date strip selects a day; the central
/// stone reflects that day — its recorded entry when one exists, or the
/// default resting state when the day is blank. "Recent Records" is backed by
/// the user's real journal entries.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.showBottomNav = true});

  /// Set false when hosted inside [MainShell] (which owns the nav).
  final bool showBottomNav;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final entriesAsync = ref.watch(journalEntriesProvider);
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final entries = entriesAsync.valueOrNull ?? const <JournalEntry>[];

    // day → that day's entries (newest first, as the provider sorts them).
    final entriesByDay = entriesByDayOfMonth(entries, now.year, now.month);
    final selectedEntries = entriesByDay[_selectedDay];

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
              _DateStrip(
                selectedDay: _selectedDay,
                entriesByDay: entriesByDay,
                onSelect: (d) => setState(() => _selectedDay = d),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              _DayState(
                year: now.year,
                month: now.month,
                day: _selectedDay,
                isToday: _selectedDay == now.day,
                entries: selectedEntries,
              ),
              const SizedBox(height: AppSpacing.stackLg),
              GlassButton(
                label: '기록하기',
                icon: Icons.add,
                variant: GlassButtonVariant.primary,
                pill: true,
                expand: true,
                onPressed: () => context.push(Routes.record),
              ),
            ],
          ),
          if (widget.showBottomNav)
            const Align(
              alignment: Alignment.bottomCenter,
              child: GlassBottomNav(active: NavItem.home),
            ),
        ],
      ),
    );
  }
}

/// The central stone for the selected day. With an entry it shows that day's
/// recorded reflection (date · time, a short title) and tints the stone with
/// the day's accent; blank days fall back to the default resting state.
class _DayState extends StatelessWidget {
  const _DayState({
    required this.year,
    required this.month,
    required this.day,
    required this.isToday,
    required this.entries,
  });

  final int year;
  final int month;
  final int day;
  final bool isToday;
  final List<JournalEntry>? entries;

  static String _title(String body) {
    if (body.isEmpty) return '감정 기록';
    final first = body.split('\n').first.trim();
    return first.length <= 12 ? first : '${first.substring(0, 12)}…';
  }

  @override
  Widget build(BuildContext context) {
    final dayEntries = entries;
    final labelStyle = AppTextStyles.labelMedium.copyWith(
      letterSpacing: 1.6,
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
    );

    // Today always shows the default resting state; blank days do too.
    if (isToday || dayEntries == null || dayEntries.isEmpty) {
      return Column(
        children: [
          Center(
            child: EmotionStone(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isToday ? "TODAY'S STATE" : '$month월 $day일',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 4),
                  Text('Balanced', style: AppTextStyles.displayLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          const _StoneCaption(),
        ],
      );
    }

    // Recorded day → that day's reflection.
    final e = dayEntries.first;
    final accent = kEntryAccents[day % kEntryAccents.length];
    final tint = kEntryTints[day % kEntryTints.length];
    final more = dayEntries.length - 1;
    final body = e.body?.trim() ?? '';

    return Column(
      children: [
        Center(
          child: EmotionStone(
            blobs: [tint, accent],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$month월 $day일', style: labelStyle),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _title(body),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLargeMobile,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Center(
          child: Text(
            more > 0
                ? '${formatEntryTime(e.createdAt)} · 외 $more개의 기록'
                : formatEntryTime(e.createdAt),
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
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

/// Horizontal date strip for the current month. Tapping a day selects it (the
/// central stone reflects the selection); recorded days show a marker dot.
/// Auto-scrolls so today is in view on first paint.
class _DateStrip extends StatefulWidget {
  const _DateStrip({
    required this.selectedDay,
    required this.entriesByDay,
    required this.onSelect,
  });

  final int selectedDay;
  final Map<int, List<JournalEntry>> entriesByDay;
  final void Function(int day) onSelect;

  @override
  State<_DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<_DateStrip> {
  static const _dow = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _itemExtent = 72.0; // 56 chip + 16 gutter
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      final todayIndex = DateTime.now().day - 1;
      final target = todayIndex * _itemExtent - 120;
      _controller.jumpTo(
        target.clamp(0.0, _controller.position.maxScrollExtent),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Only show days up to (and including) today — never future days.
    final lastDay = now.day;

    return SizedBox(
      height: 88,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemExtent: _itemExtent,
        itemCount: lastDay,
        itemBuilder: (_, i) {
          final day = i + 1;
          final date = DateTime(now.year, now.month, day);
          final isToday = day == now.day;
          final hasEntry = widget.entriesByDay[day]?.isNotEmpty ?? false;
          // Only days with a record (and today, for the default view) are
          // selectable; empty days are dimmed and inert.
          final selectable = hasEntry || isToday;
          final selected = day == widget.selectedDay;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.gutter),
            child: Opacity(
              opacity: selectable ? 1.0 : 0.4,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: selectable ? () => widget.onSelect(day) : null,
                child: Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppRadii.rXxl,
                    border: selected
                        ? null
                        : Border.all(color: AppGlass.edge, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dow[date.weekday - 1],
                        style: AppTextStyles.labelMedium.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '$day',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasEntry
                              ? (selected ? Colors.white : AppColors.primary)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
