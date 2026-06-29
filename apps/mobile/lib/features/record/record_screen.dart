import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_core/mental_stone_core.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';

/// Screen 03 — Record. Writes a new entry (then continues to the analysis
/// flow), or edits an existing [entry] in place when one is passed.
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key, this.entry});

  /// When non-null the screen runs in edit mode: it preloads this entry's
  /// body, saves with `update`, and pops back instead of starting analysis.
  final JournalEntry? entry;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.entry?.body ?? '');
  bool _saving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('기록할 내용을 입력해주세요.')));
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(journalRepositoryProvider);
      if (_isEditing) {
        await repo.update(widget.entry!.id, body: text);
        ref.invalidate(journalEntriesProvider);
        if (mounted) context.pop();
      } else {
        await repo.create(userId: user.id, body: text);
        ref.invalidate(journalEntriesProvider);
        if (mounted) context.push(Routes.analysis);
      }
    } catch (e) {
      debugPrint('[record.save] failed: $e');
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
      appBar: MentalStoneAppBar(back: true, onLeading: () => context.pop()),
      body: Stack(
        children: [
          const EtherealBackground(variant: AuraVariant.record),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.marginPage,
              MediaQuery.paddingOf(context).top + 52,
              AppSpacing.marginPage,
              112,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? '기록 수정' : '지금 이 순간',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: AppSpacing.stackSm),
                Text(
                  _isEditing ? '내용을\n다듬어 보세요.' : '당신의 감정을\n돌에 담아보세요.',
                  style: AppTextStyles.headlineLargeMobile,
                ),
                const SizedBox(height: AppSpacing.stackLg),
                Expanded(
                  child: GlassInput(
                    controller: _controller,
                    expands: true,
                    enabled: !_saving,
                    hintText: '오늘 하루는 어땠나요? 당신의 솔직한 감정을 적어주세요...',
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage,
                0,
                AppSpacing.marginPage,
                40,
              ),
              child: GlassButton(
                label: _isEditing ? '수정 완료' : '기록 완료',
                icon: Icons.done_all,
                variant: GlassButtonVariant.glass,
                pill: true,
                expand: true,
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
