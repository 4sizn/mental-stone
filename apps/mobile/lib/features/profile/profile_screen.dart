import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';

/// Which auth action is currently in flight, so a failure shows the right
/// message and the spinner sits on the button that was pressed.
enum _ProfileAction { none, signOut, delete }

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  _ProfileAction _action = _ProfileAction.none;

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정말 탈퇴하시겠어요?'),
        content: const Text(
          '계정과 모든 감정 기록이 영구적으로 삭제되며, 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _action = _ProfileAction.delete);
    await ref.read(authControllerProvider.notifier).deleteAccount();
    // On success the session ends and the router redirects away from here;
    // on failure the listener below surfaces a message.
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final user = ref.watch(currentUserProvider);
    final busy = ref.watch(authControllerProvider).isLoading;
    final signingOut = busy && _action != _ProfileAction.delete;
    final deleting = busy && _action == _ProfileAction.delete;

    // Surface a sign-out / delete failure (sign-in/up errors show on their
    // own screens). The message depends on which action was attempted.
    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError && context.mounted) {
        final message = _action == _ProfileAction.delete
            ? '회원 탈퇴에 실패했어요. 다시 시도해 주세요.'
            : '로그아웃에 실패했어요. 다시 시도해 주세요.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(
        back: true,
        subtitle: 'Profile',
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
              profileAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => GlassCard(
                  child: Text(
                    '프로필을 불러오지 못했어요.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                data: (profile) {
                  final name =
                      profile?.name ??
                      user?.email?.split('@').first ??
                      'Friend';
                  final email = profile?.email ?? user?.email ?? '';
                  return Column(
                    children: [
                      _Avatar(url: profile?.avatarUrl),
                      const SizedBox(height: AppSpacing.stackMd),
                      Text(name, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(email, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppSpacing.stackLg),
                      GlassCard(
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.badge_outlined,
                              label: '이름',
                              value: name,
                            ),
                            const Divider(color: Color(0x22000000), height: 24),
                            _InfoRow(
                              icon: Icons.mail_outline,
                              label: '이메일',
                              value: email.isEmpty ? '—' : email,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.stackLg),
              GlassButton(
                label: '프로필 수정',
                icon: Icons.edit_outlined,
                variant: GlassButtonVariant.glass,
                pill: true,
                expand: true,
                onPressed: busy ? null : () => context.push(Routes.profileEdit),
              ),
              const SizedBox(height: AppSpacing.stackSm),
              GlassButton(
                label: '로그아웃',
                icon: Icons.logout,
                variant: GlassButtonVariant.glass,
                pill: true,
                expand: true,
                loading: signingOut,
                onPressed: busy
                    ? null
                    : () {
                        setState(() => _action = _ProfileAction.signOut);
                        ref.read(authControllerProvider.notifier).signOut();
                      },
              ),
              const SizedBox(height: AppSpacing.stackSm),
              TextButton.icon(
                onPressed: busy ? null : _confirmAndDelete,
                icon: deleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    : const Icon(Icons.person_remove_outlined, size: 18),
                label: const Text('회원 탈퇴'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondaryContainer,
        border: Border.all(color: AppGlass.edgeStrong, width: 2),
        image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
        boxShadow: const [BoxShadow(color: Color(0x33BADBF5), blurRadius: 32)],
      ),
      child: url == null
          ? const Icon(
              Icons.person,
              size: 44,
              color: AppColors.onSecondaryContainer,
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.labelMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
