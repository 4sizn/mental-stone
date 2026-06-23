import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_stone_core/mental_stone_core.dart';

// TODO: replace this whole file with real aggregation once per-entry emotions
// are persisted. Today no entry stores an emotion, so the Records tab is
// driven by deterministic placeholder data. When emotions are saved, compute
// counts/records from `journalEntriesProvider` here and the UI stays unchanged.

/// Placeholder occurrence counts per emotion (absent = not yet collected).
const Map<Emotion, int> _mockCounts = {
  Emotion.anger: 12,
  Emotion.annoyed: 9,
  Emotion.regret: 7,
  Emotion.bored: 6,
  Emotion.guilty: 5,
  Emotion.discouraged: 4,
  Emotion.surprised: 3,
  Emotion.shy: 2,
  Emotion.embarrassed: 2,
  Emotion.powerless: 1,
};

/// Count for every emotion in catalog order (0 when not yet collected).
final emotionCountsProvider = Provider<Map<Emotion, int>>((ref) {
  return {for (final e in Emotion.values) e: _mockCounts[e] ?? 0};
});

/// The records that contain a given emotion. (Placeholder sample entries.)
final recordsByEmotionProvider = Provider.family<List<JournalEntry>, Emotion>((
  ref,
  emotion,
) {
  final count = _mockCounts[emotion] ?? 0;
  final base = DateTime(2026, 6, 24, 21, 30);
  return List.generate(count, (i) {
    return JournalEntry(
      id: '${emotion.key}-$i',
      userId: 'mock',
      createdAt: base.subtract(Duration(days: i * 3 + 1)),
      mood: emotion.key,
      body:
          '${emotion.nameKo} 감정이 담긴 기록 샘플입니다. '
          '실제 기록 데이터 연동 시 이 자리에 본문이 표시됩니다.',
    );
  });
});
