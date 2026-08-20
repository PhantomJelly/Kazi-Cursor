import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class AboutKaziScreen extends StatelessWidget {
  const AboutKaziScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: Scaffold(
        backgroundColor: KaziColors.white,
        appBar: AppBar(
          backgroundColor: KaziColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(t(context, 'about.title'), style: KaziTextStyles.button),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Kazi', style: KaziTextStyles.heading),
            const SizedBox(height: 8),
            Text(
              t(context, 'auth.tagline'),
              style: KaziTextStyles.subtitle.copyWith(
                color: KaziColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t(context, 'about.body'),
              style: KaziTextStyles.input,
            ),
            const SizedBox(height: 28),
            _AboutRow(label: t(context, 'common.version'), value: '1.0.0'),
            _AboutRow(label: t(context, 'common.region'), value: t(context, 'common.namibia')),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(label, style: KaziTextStyles.label)),
          Text(value, style: KaziTextStyles.input),
        ],
      ),
    );
  }
}
