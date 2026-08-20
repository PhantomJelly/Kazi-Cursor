import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: KaziColors.grey15, thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label ?? t(context, 'common.or'),
            style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
          ),
        ),
        const Expanded(child: Divider(color: KaziColors.grey15, thickness: 1.5)),
      ],
    );
  }
}
