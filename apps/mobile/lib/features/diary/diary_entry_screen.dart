import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../router/app_router.dart';
import '../../widgets/journal_summary_card.dart';

/// Screen 02 — Diary Entry (read view). Renders a real [entry] when one is
/// passed (via go_router `extra`); falls back to a designed sample otherwise.
class DiaryEntryScreen extends StatelessWidget {
  const DiaryEntryScreen({super.key, this.entry});

  final JournalEntry? entry;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    if (e != null) return _RealDiaryView(entry: e);
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
          const EtherealBackground(variant: AuraVariant.home),
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.marginPage,
              MediaQuery.paddingOf(context).top + 52,
              AppSpacing.marginPage,
              40,
            ),
            children: [
              const Center(child: _HeroStone()),
              const SizedBox(height: AppSpacing.stackMd),
              Center(
                child: Column(
                  children: [
                    const EmotionChip(
                      label: 'Calm & Reflective',
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    Text(
                      'The Silence of Morning',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLargeMobile,
                    ),
                    Text(
                      'Monday, October 14 • 7:30 AM',
                      style: AppTextStyles.bodyMedium,
                    ),
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
                          left: BorderSide(color: Color(0x335D5F5F), width: 4),
                        ),
                      ),
                      child: Text(
                        '"I woke up before the alarm today. The light was '
                        'filtering through the curtains in a way that felt '
                        'like a quiet conversation..."',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurface,
                        ),
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
                        color: AppColors.onSurface.withValues(alpha: 0.8),
                      ),
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
                        Row(
                          children: [
                            const Icon(
                              Icons.analytics,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Emotional Spectrum',
                              style: AppTextStyles.headlineMedium,
                            ),
                          ],
                        ),
                        Text('AI Analysis', style: AppTextStyles.labelMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    const GlowBar(
                      label: 'Serenity',
                      value: 0.85,
                      color: AppColors.moodSerenity,
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    const GlowBar(
                      label: 'Clarity',
                      value: 0.72,
                      color: AppColors.moodClarity,
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    const GlowBar(
                      label: 'Vitality',
                      value: 0.45,
                      color: AppColors.moodVitality,
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Text(
                      '"Your entry suggests a high state of mindful presence '
                      'and a significant reduction in cortisol markers."',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0,
                      ),
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
                      onPressed: () => Share.share(
                        'The Silence of Morning\n\n'
                        '"I woke up before the alarm today..."\n\n'
                        '— Mental Stone',
                      ),
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

/// Real diary view backed by a user [JournalEntry].
class _RealDiaryView extends ConsumerWidget {
  const _RealDiaryView({required this.entry});
  final JournalEntry entry;

  String _title(String body) {
    if (body.isEmpty) return '오늘의 감정 기록';
    final firstLine = body.split('\n').first.trim();
    return firstLine.length <= 22 ? firstLine : '${firstLine.substring(0, 22)}…';
  }

  /// Resolves the freshest copy of [entry] from the live list, falling back to
  /// the route-supplied entry while the list is loading or after deletion.
  JournalEntry _latest(WidgetRef ref) {
    final list = ref.watch(journalEntriesProvider).valueOrNull;
    if (list != null) {
      for (final e in list) {
        if (e.id == entry.id) return e;
      }
    }
    return entry;
  }

  /// Text put on the system share sheet: date, optional mood, body, signature.
  String _shareText(JournalEntry entry) {
    final body = entry.body?.trim() ?? '';
    final mood = entry.mood?.trim();
    final when =
        '${formatEntryDate(entry.createdAt)} · ${formatEntryTime(entry.createdAt)}';
    final buffer = StringBuffer(when);
    if (mood != null && mood.isNotEmpty) buffer.write('\n#$mood');
    if (body.isNotEmpty) buffer.write('\n\n$body');
    buffer.write('\n\n— Mental Stone');
    return buffer.toString();
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('이 기록을 삭제할까요?'),
        content: const Text('삭제한 감정 기록은 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제하기'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(journalRepositoryProvider).delete(entry.id);
      ref.invalidate(journalEntriesProvider);
      if (context.mounted) context.pop();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제에 실패했어요. 다시 시도해 주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-read the freshest version of this entry from the list so an in-place
    // edit (which invalidates [journalEntriesProvider]) refreshes this view
    // too. Falls back to the entry passed via route `extra` while the list is
    // loading or if it's no longer present (e.g. just deleted).
    final entry = _latest(ref);
    final body = entry.body?.trim() ?? '';
    final mood = entry.mood?.trim();
    final topPad = MediaQuery.paddingOf(context).top + 52;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(
        back: true,
        subtitle: 'Diary Entry',
        onLeading: () => context.pop(),
        actions: [
          _GlassAction(
            icon: Icons.edit_outlined,
            semanticLabel: '수정',
            onTap: () => context.push(Routes.record, extra: entry),
          ),
          _GlassAction(
            icon: Icons.delete_outline,
            semanticLabel: '삭제',
            onTap: () => _confirmAndDelete(context, ref),
          ),
        ],
      ),
      body: Stack(
        children: [
          const EtherealBackground(variant: AuraVariant.home),
          ListView(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.marginPage, topPad, AppSpacing.marginPage, 40),
            children: [
              const Center(child: _HeroStone()),
              const SizedBox(height: AppSpacing.stackMd),
              Center(
                child: Column(
                  children: [
                    if (mood != null && mood.isNotEmpty) ...[
                      EmotionChip(label: mood, color: AppColors.secondary),
                      const SizedBox(height: AppSpacing.stackSm),
                    ],
                    Text(_title(body),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLargeMobile),
                    const SizedBox(height: 4),
                    Text(
                      '${formatEntryDate(entry.createdAt)} · ${formatEntryTime(entry.createdAt)}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      body.isEmpty ? '작성된 내용이 없어요.' : body,
                      style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurface, height: 1.6),
                    ),
                    if (mood != null && mood.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.stackMd),
                      Wrap(
                        spacing: AppSpacing.stackSm,
                        runSpacing: AppSpacing.stackSm,
                        children: [EmotionChip(label: '#$mood', tonal: false)],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: '공유하기',
                      variant: GlassButtonVariant.glass,
                      expand: true,
                      onPressed: () => Share.share(_shareText(entry)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.stackMd),
                  Expanded(
                    child: GlassButton(
                      label: '보관하기',
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

/// Small round frosted button for the app bar's trailing actions (edit /
/// delete), mirroring the back button's glass-circle style.
class _GlassAction extends StatelessWidget {
  const _GlassAction({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.28),
                border: Border.all(color: AppGlass.edge, width: 1),
              ),
              child: Icon(icon, color: AppColors.onSurface, size: 22),
            ),
          ),
        ),
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
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
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
