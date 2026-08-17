import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

enum KaziButtonVariant { primary, outline }

class KaziButton extends StatelessWidget {
  const KaziButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KaziButtonVariant.primary,
    this.leading,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final KaziButtonVariant variant;
  final Widget? leading;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == KaziButtonVariant.primary;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              isPrimary ? KaziColors.primary : KaziColors.white,
          foregroundColor:
              isPrimary ? KaziColors.onPrimary : KaziColors.textPrimary,
          disabledBackgroundColor:
              isPrimary ? KaziColors.primary : KaziColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: KaziColors.grey15, width: 1.5),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isPrimary
                      ? KaziColors.grey
                      : KaziColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Text(
                    label,
                    style: KaziTextStyles.button.copyWith(
                      color: isPrimary
                          ? KaziColors.grey
                          : KaziColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
