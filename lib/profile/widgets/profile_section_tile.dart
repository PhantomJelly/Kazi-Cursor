import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class ProfileSectionTile extends StatelessWidget {
  const ProfileSectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.onTap,
    this.isLocked = false,
    this.isBonus = false,
  });

  final String title;
  final String subtitle;
  final bool isComplete;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isBonus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KaziColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KaziColors.grey15, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isComplete
                    ? KaziColors.primaryTint
                    : KaziColors.grey8,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked
                    ? Icons.lock_outline
                    : isComplete
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                color: isComplete || isLocked
                    ? KaziColors.primary
                    : KaziColors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title, style: KaziTextStyles.button),
                      ),
                      if (isBonus) ...[
                        const SizedBox(width: 8),
                        Text(
                          'BONUS',
                          style: KaziTextStyles.button.copyWith(
                            fontSize: 11,
                            color: KaziColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Icon(Icons.star,
                            color: KaziColors.primary, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isLocked ? KaziColors.grey30 : KaziColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
