import 'package:flutter/foundation.dart';

/// A row of `public.profiles`.
@immutable
class Profile {
  const Profile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;

  /// Best label for the user in the UI.
  String get name => (displayName?.trim().isNotEmpty ?? false)
      ? displayName!.trim()
      : (email?.split('@').first ?? 'Friend');

  factory Profile.fromMap(Map<String, dynamic> map) {
    final created = map['created_at'];
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String?,
      displayName: map['display_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }

  Profile copyWith({String? displayName, String? avatarUrl}) => Profile(
    id: id,
    email: email,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName &&
      other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, email, displayName, avatarUrl);
}
