/// Mental Stone — core data & domain layer.
///
/// Supabase client wiring, authentication, profile and journal repositories,
/// all exposed through Riverpod providers. The app depends on this package
/// and never talks to Supabase directly.
library;

// Re-export the Supabase types the app commonly needs so feature code can
// depend on `mental_stone_core` alone.
export 'package:supabase_flutter/supabase_flutter.dart'
    show
        Supabase,
        SupabaseClient,
        User,
        Session,
        AuthState,
        AuthChangeEvent,
        AuthException,
        OAuthProvider;

export 'src/supabase/supabase_providers.dart';
export 'src/auth/auth_repository.dart';
export 'src/auth/auth_providers.dart';
export 'src/auth/auth_controller.dart';
export 'src/auth/auth_failure.dart';
export 'src/profile/profile.dart';
export 'src/profile/profile_repository.dart';
export 'src/journal/journal_entry.dart';
export 'src/journal/journal_repository.dart';
