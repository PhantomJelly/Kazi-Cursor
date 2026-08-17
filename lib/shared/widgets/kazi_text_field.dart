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
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final bool useLightLabels;

  @override
  Widget build(BuildContext context) {
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
              borderSide: const BorderSide(color: KaziColors.grey15, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: KaziColors.grey15, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: KaziColors.primary, width: 1.5),
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
