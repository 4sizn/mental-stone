import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final user = ref.watch(currentUserProvider);
    final busy = ref.watch(authControllerProvider).isLoading;

    // Surface a sign-out failure (sign-in/up errors are shown on their screens).
    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃에 실패했어요. 다시 시도해 주세요.')),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginPage,
              112,
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
                label: '로그아웃',
                icon: Icons.logout,
                variant: GlassButtonVariant.glass,
                pill: true,
                expand: true,
                loading: busy,
                onPressed: busy
                    ? null
                    : () => ref.read(authControllerProvider.notifier).signOut(),
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
