import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';

class InquirySentScreen extends StatelessWidget {
  const InquirySentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: Scaffold(
        backgroundColor: KaziColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: KaziColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: KaziColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(t(context, 'inquiry.sent'), style: KaziTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  t(context, 'inquiry.sentBody'),
                  style: KaziTextStyles.subtitle.copyWith(
                    color: KaziColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                KaziButton(
                  label: t(context, 'common.done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
