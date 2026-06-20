import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Frosted text field with a floating label (DESIGN.md › Input Fields).
class GlassInput extends StatelessWidget {
  const GlassInput({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
        ],
        ClipRRect(
          borderRadius: AppRadii.rXxl,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: AppGlass.opacityInput),
                borderRadius: AppRadii.rXxl,
                border: Border.all(
                  color: hasError
                      ? AppColors.error.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.glassPadding),
              child: TextField(
                controller: controller,
                maxLines: expands ? null : maxLines,
                minLines: minLines,
                expands: expands,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                autofillHints: autofillHints,
                enabled: enabled,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                cursorColor: AppColors.primary,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: hintText,
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              errorText!,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
