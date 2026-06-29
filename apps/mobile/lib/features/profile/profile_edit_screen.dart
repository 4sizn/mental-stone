import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

/// Edit the signed-in user's profile. v1 edits the display name only — avatar
/// upload needs Storage setup and is out of scope.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _name = TextEditingController(
    text: ref.read(myProfileProvider).valueOrNull?.displayName ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _name.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이름을 입력해주세요.')));
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .update(user.id, displayName: text);
      ref.invalidate(myProfileProvider);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('저장에 실패했어요. 다시 시도해 주세요.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: MentalStoneAppBar(
        back: true,
        subtitle: 'Edit Profile',
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
              Text('프로필 수정', style: AppTextStyles.labelMedium),
              const SizedBox(height: AppSpacing.stackSm),
              Text('이름을\n바꿔보세요.', style: AppTextStyles.headlineLargeMobile),
              const SizedBox(height: AppSpacing.stackLg),
              GlassInput(
                controller: _name,
                label: '이름',
                hintText: '표시할 이름을 입력하세요',
                enabled: !_saving,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _saving ? null : _save(),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              GlassButton(
                label: '저장',
                icon: Icons.check,
                variant: GlassButtonVariant.glass,
                pill: true,
                expand: true,
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
