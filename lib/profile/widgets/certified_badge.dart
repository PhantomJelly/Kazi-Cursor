import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class CertifiedBadge extends StatelessWidget {
  const CertifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: KaziColors.primaryTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KaziColors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            color: KaziColors.primary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Certified',
            style: KaziTextStyles.button.copyWith(
              fontSize: 13,
              color: KaziColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
