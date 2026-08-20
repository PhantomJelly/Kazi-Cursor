import 'package:flutter/material.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class ProfileProgressBar extends StatelessWidget {
  const ProfileProgressBar({
    super.key,
    required this.progress,
    required this.completedSections,
    required this.totalSections,
    this.bonusComplete,
  });

  final double progress;
  final int completedSections;
  final int totalSections;
  final bool? bonusComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t(context, 'profile.completion'), style: KaziTextStyles.label),
            Text(
              t(context, 'profile.ofComplete', {
                'done': '$completedSections',
                'total': '$totalSections',
              }),
              style: KaziTextStyles.subtitle.copyWith(
                fontSize: 13,
                color: KaziColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: KaziColors.grey8,
            color: KaziColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t(context, 'profile.percentComplete', {
            'percent': '${(progress * 100).round()}',
          }),
          style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
        ),
        if (bonusComplete != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: KaziColors.grey8,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KaziColors.grey15, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  bonusComplete! ? Icons.check_circle : Icons.star_outline,
                  color: bonusComplete!
                      ? KaziColors.primary
                      : KaziColors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t(context, 'profile.bonus'),
                  style: KaziTextStyles.button.copyWith(
                    fontSize: 12,
                    color: KaziColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Icon(Icons.star, color: KaziColors.primary, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(context, 'profile.certifications'),
                    style: KaziTextStyles.subtitle.copyWith(
                      fontSize: 13,
                      color: KaziColors.textPrimary,
                    ),
                  ),
                ),
                if (bonusComplete!)
                  const Icon(Icons.check_rounded,
                      color: KaziColors.primary, size: 18),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
