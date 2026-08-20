import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class KaziTextField extends StatelessWidget {
  const KaziTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.useLightLabels = false,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final bool useLightLabels;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: KaziColors.statusPending, width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: useLightLabels
              ? KaziTextStyles.labelLight
              : KaziTextStyles.label,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: KaziTextStyles.input.copyWith(
            color: useLightLabels ? KaziColors.grey : KaziColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: KaziTextStyles.input.copyWith(
              color: useLightLabels ? KaziColors.grey60 : KaziColors.textHint,
            ),
            filled: true,
            fillColor: KaziColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? KaziColors.statusPending : KaziColors.grey15,
                width: 1.5,
              ),
            ),
            enabledBorder: hasError
                ? errorBorder
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: KaziColors.grey15,
                      width: 1.5,
                    ),
                  ),
            focusedBorder: hasError
                ? errorBorder
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: KaziColors.primary,
                      width: 1.5,
                    ),
                  ),
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            suffixIcon: suffix,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: KaziTextStyles.subtitle.copyWith(
              color: KaziColors.statusPending,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
