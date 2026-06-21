import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../router/app_router.dart';

const List<Color> kEntryAccents = [
  AppColors.tertiary,
  AppColors.secondary,
  AppColors.primary,
];
const List<Color> kEntryTints = [
  AppColors.tertiaryFixed,
  AppColors.secondaryFixed,
  AppColors.surfaceVariant,
];

const _weekdayKo = ['월', '화', '수', '목', '금', '토', '일'];

String formatEntryDate(DateTime utc) {
  final d = utc.toLocal();
  return '${d.month}월 ${d.day}일 ${_weekdayKo[d.weekday - 1]}요일';
}

String formatEntryTime(DateTime utc) {
  final d = utc.toLocal();
  final ampm = d.hour < 12 ? '오전' : '오후';
  var h = d.hour % 12;
  if (h == 0) h = 12;
  return '$ampm $h:${d.minute.toString().padLeft(2, '0')}';
}

/// A real journal entry rendered as a "최근 일기 요약" card (design Frame 6).
class JournalSummaryCard extends StatelessWidget {
  const JournalSummaryCard({
    super.key,
    required this.entry,
    required this.accent,
    required this.tint,
  });

  final JournalEntry entry;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final body = entry.body?.trim() ?? '';
    final mood = entry.mood?.trim();
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
                color: accent.withValues(alpha: 0.9),
              ),
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
                    Text(
                      formatEntryDate(entry.createdAt),
                      style: AppTextStyles.labelMedium.copyWith(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      formatEntryTime(entry.createdAt),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12,
                        letterSpacing: 0,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body.isEmpty ? '오늘의 감정 기록' : body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium,
                ),
                if (mood != null && mood.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.stackSm),
                  EmotionChip(label: '#$mood', tonal: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
