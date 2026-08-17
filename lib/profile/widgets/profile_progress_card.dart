import 'package:flutter/material.dart';
import 'package:kazi/profile/widgets/profile_progress_bar.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

class ProfileProgressCard extends StatelessWidget {
  const ProfileProgressCard({
    super.key,
    required this.progress,
    required this.completedSections,
    required this.totalSections,
    required this.onTap,
    this.bonusComplete,
  });

  final double progress;
  final int completedSections;
  final int totalSections;
  final VoidCallback onTap;
  final bool? bonusComplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KaziColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KaziColors.grey15, width: 1.5),
        ),
        child: ProfileProgressBar(
          progress: progress,
          completedSections: completedSections,
          totalSections: totalSections,
          bonusComplete: bonusComplete,
        ),
      ),
    );
  }
}
