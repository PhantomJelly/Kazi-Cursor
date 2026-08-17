import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: KaziTextStyles.footer),
        GestureDetector(
          onTap: onTap,
          child: Text(' $actionLabel', style: KaziTextStyles.footerLink),
        ),
      ],
    );
  }
}
