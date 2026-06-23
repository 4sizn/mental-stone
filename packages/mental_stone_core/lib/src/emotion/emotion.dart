import 'dart:ui' show Color;

/// The canonical set of "emotion stones" a journal entry can be tagged with.
///
/// [key] is the stable string persisted to `journal_entries.mood` (or a future
/// per-entry emotions table); [nameKo]/[nameEn] and [color] drive the UI. The
/// colors are taken from the design reference sheet (kept as literals so this
/// catalog has no dependency on the UI package).
enum Emotion {
  anger,
  annoyed,
  frustrated,
  jealous,
  discouraged,
  shy,
  ashamed,
  inferior,
  guilty,
  regret,
  emotionless,
  powerless,
  bored,
  embarrassed,
  surprised,
}

extension EmotionInfo on Emotion {
  /// Stable identifier persisted with an entry.
  String get key => name;

  String get nameKo => switch (this) {
    Emotion.anger => '분노',
    Emotion.annoyed => '짜증',
    Emotion.frustrated => '억울함',
    Emotion.jealous => '질투',
    Emotion.discouraged => '좌절',
    Emotion.shy => '부끄러움',
    Emotion.ashamed => '수치심',
    Emotion.inferior => '열등감',
    Emotion.guilty => '죄책감',
    Emotion.regret => '후회',
    Emotion.emotionless => '무감정',
    Emotion.powerless => '무력감',
    Emotion.bored => '지루함',
    Emotion.embarrassed => '당황',
    Emotion.surprised => '놀람',
  };

  String get nameEn => switch (this) {
    Emotion.anger => 'ANGER',
    Emotion.annoyed => 'ANNOYED',
    Emotion.frustrated => 'FRUSTRATED',
    Emotion.jealous => 'JEALOUS',
    Emotion.discouraged => 'DISCOURAGED',
    Emotion.shy => 'SHY',
    Emotion.ashamed => 'ASHAMED',
    Emotion.inferior => 'INFERIOR',
    Emotion.guilty => 'GUILTY',
    Emotion.regret => 'REGRET',
    Emotion.emotionless => 'EMOTIONLESS',
    Emotion.powerless => 'POWERLESS',
    Emotion.bored => 'BORED',
    Emotion.embarrassed => 'EMBARRASSED',
    Emotion.surprised => 'SURPRISED',
  };

  /// Stone color, from the design reference sheet.
  Color get color => switch (this) {
    Emotion.anger => const Color(0xFFF5945C),
    Emotion.annoyed => const Color(0xFFF49AC2),
    Emotion.frustrated => const Color(0xFFA8D8C8),
    Emotion.jealous => const Color(0xFFF7C49B),
    Emotion.discouraged => const Color(0xFFA9AAB0),
    Emotion.shy => const Color(0xFFF7C5D9),
    Emotion.ashamed => const Color(0xFF8E5C6E),
    Emotion.inferior => const Color(0xFFD8C0A0),
    Emotion.guilty => const Color(0xFFC9B6E4),
    Emotion.regret => const Color(0xFF6E9BD1),
    Emotion.emotionless => const Color(0xFFBFC1C6),
    Emotion.powerless => const Color(0xFFE6C166),
    Emotion.bored => const Color(0xFFEDE4CC),
    Emotion.embarrassed => const Color(0xFFF3A07A),
    Emotion.surprised => const Color(0xFFF2D04E),
  };
}

/// Resolves a persisted [key] back to its [Emotion] (null if unknown).
Emotion? emotionFromKey(String? key) {
  if (key == null) return null;
  for (final e in Emotion.values) {
    if (e.key == key) return e;
  }
  return null;
}
