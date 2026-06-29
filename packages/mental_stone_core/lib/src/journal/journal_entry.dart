import 'package:flutter/foundation.dart';

/// A row of `public.journal_entries` — one recorded emotion / diary moment.
@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.mood,
    this.body,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final String? mood;
  final String? body;

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      mood: map['mood'] as String?,
      body: map['body'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Groups [entries] by day-of-month for the given [year]/[month], comparing in
/// local time. Shared by the Home and Calendar tabs so both bucket a day's
/// entries identically. Entry order within a day is preserved (the provider
/// already sorts newest-first).
Map<int, List<JournalEntry>> entriesByDayOfMonth(
  Iterable<JournalEntry> entries,
  int year,
  int month,
) {
  final byDay = <int, List<JournalEntry>>{};
  for (final e in entries) {
    final d = e.createdAt.toLocal();
    if (d.year == year && d.month == month) {
      (byDay[d.day] ??= <JournalEntry>[]).add(e);
    }
  }
  return byDay;
}
