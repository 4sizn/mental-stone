import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import 'auth_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@')) {
      setState(() => _localError = '올바른 이메일을 입력해 주세요.');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = '비밀번호는 6자 이상이어야 합니다.');
      return;
    }
    setState(() => _localError = null);
    // On success the auth stream fires and the router redirects to home.
    await ref.read(authControllerProvider.notifier).signUp(
          email: email,
          password: password,
          displayName: _name.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading;
    final error = _localError ??
        (state.hasError ? authErrorMessage(state.error!) : null);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: EmotionStone(
              size: 120,
              blobs: [AppColors.tertiaryFixed, AppColors.moodHappy],
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Text('감정의 여정을 시작하세요',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLargeMobile),
          const SizedBox(height: AppSpacing.stackSm),
          Text('당신만의 감정 스톤을 모아보세요.',
              textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.stackLg),
          GlassCard(
            child: Column(
              children: [
                GlassInput(
                  controller: _name,
                  label: '이름 (선택)',
                  hintText: '표시될 이름',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                GlassInput(
                  controller: _email,
                  label: '이메일',
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                GlassInput(
                  controller: _password,
                  label: '비밀번호',
                  hintText: '6자 이상',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => loading ? null : _submit(),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.stackMd),
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(error,
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.stackLg),
                GlassButton(
                  label: '가입하기',
                  expand: true,
                  pill: true,
                  loading: loading,
                  onPressed: loading ? null : _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          TextButton(
            onPressed: loading ? null : () => context.pop(),
            child: Text.rich(
              TextSpan(
                text: '이미 계정이 있으신가요?  ',
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(
                    text: '로그인',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
