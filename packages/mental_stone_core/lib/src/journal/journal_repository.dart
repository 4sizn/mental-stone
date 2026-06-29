import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_providers.dart';
import '../supabase/session_retry.dart';
import '../supabase/supabase_providers.dart';
import 'journal_entry.dart';

/// CRUD over `public.journal_entries`. RLS restricts every row to its owner.
class JournalRepository {
  JournalRepository(this._client);

  final SupabaseClient _client;

  Future<List<JournalEntry>> list(String userId) async {
    final rows = await _client
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map((e) => JournalEntry.fromMap(e)).toList(growable: false);
  }

  Future<JournalEntry> create({
    required String userId,
    String? mood,
    String? body,
  }) {
    return runWithFreshSession(_client.auth, () async {
      final row = await _client
          .from('journal_entries')
          .insert({'user_id': userId, 'mood': mood, 'body': body})
          .select()
          .single();
      return JournalEntry.fromMap(row);
    });
  }

  Future<JournalEntry> update(String id, {String? mood, String? body}) {
    final patch = <String, dynamic>{};
    if (mood != null) patch['mood'] = mood;
    if (body != null) patch['body'] = body;
    return runWithFreshSession(_client.auth, () async {
      final row = await _client
          .from('journal_entries')
          .update(patch)
          .eq('id', id)
          .select()
          .single();
      return JournalEntry.fromMap(row);
    });
  }

  Future<void> delete(String id) {
    return runWithFreshSession(_client.auth, () async {
      await _client.from('journal_entries').delete().eq('id', id);
    });
  }
}

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(supabaseClientProvider));
});

/// The signed-in user's entries, newest first (empty when signed out).
final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(journalRepositoryProvider).list(user.id);
});
