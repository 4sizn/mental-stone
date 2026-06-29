import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_providers.dart';
import '../supabase/session_retry.dart';
import '../supabase/supabase_providers.dart';
import 'profile.dart';

/// Reads/updates `public.profiles`. RLS restricts every row to its owner.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> fetch(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data == null ? null : Profile.fromMap(data);
  }

  Future<Profile> update(
    String userId, {
    String? displayName,
    String? avatarUrl,
  }) {
    final patch = <String, dynamic>{};
    if (displayName != null) patch['display_name'] = displayName;
    if (avatarUrl != null) patch['avatar_url'] = avatarUrl;
    return runWithFreshSession(_client.auth, () async {
      final data = await _client
          .from('profiles')
          .update(patch)
          .eq('id', userId)
          .select()
          .single();
      return Profile.fromMap(data);
    });
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

/// The signed-in user's profile (null when signed out).
final myProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).fetch(user.id);
});
