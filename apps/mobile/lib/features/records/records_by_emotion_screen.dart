import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../widgets/journal_summary_card.dart';
import 'records_providers.dart';
import 'records_screen.dart' show StoneBadge;

/// Every record that contains a given [emotion] stone.
///
/// [emotion] may be null when the route is restored/deep-linked without its
/// `extra` payload; in that case we fall back to a "no records" view rather
/// than crashing.
class RecordsByEmotionScreen extends ConsumerWidget {
  const RecordsByEmotionScreen({super.key, required this.emotion});

  final Emotion? emotion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotion = this.emotion;
    if (emotion == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: MentalStoneAppBar(back: true, onLeading: () => context.pop()),
        body: Stack(
          children: [
            const EtherealBackground(variant: AuraVariant.records),
            Center(child: _empty()),
          ],
        ),
      );
    }

    final entries = ref.watch(recordsByEmotionProvider(emotion));
    final topPad = MediaQuery.paddingOf(context).top + 52;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(back: true, onLeading: () => context.pop()),
      body: Stack(
        children: [
          const EtherealBackground(variant: AuraVariant.records),
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.marginPage,
              topPad,
              AppSpacing.marginPage,
              40,
            ),
            children: [
              Row(
                children: [
                  StoneBadge(color: emotion.color, size: 64),
                  const SizedBox(width: AppSpacing.gutter),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emotion.nameKo,
                          style: AppTextStyles.headlineLargeMobile,
                        ),
                        Text(
                          '${emotion.nameEn} · ${entries.length}개의 기록',
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.stackLg),
              if (entries.isEmpty)
                _empty()
              else
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                    child: JournalSummaryCard(
                      entry: entries[i],
                      accent: kEntryAccents[i % kEntryAccents.length],
                      tint: kEntryTints[i % kEntryTints.length],
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() => GlassCard(
    child: Column(
      children: [
        const Icon(
          Icons.spa_outlined,
          color: AppColors.onSurfaceVariant,
          size: 28,
        ),
        const SizedBox(height: AppSpacing.stackSm),
        Text('이 감정의 기록이 아직 없어요', style: AppTextStyles.bodyMedium),
      ],
    ),
  );
}
