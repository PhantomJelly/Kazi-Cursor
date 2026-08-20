import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/contact_actions.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supportEmail = t(context, 'help.emailAddress');
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
          title: Text(t(context, 'help.title'), style: KaziTextStyles.button),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              t(context, 'help.needHand'),
              style: KaziTextStyles.heading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              t(context, 'help.intro'),
              style: KaziTextStyles.subtitle.copyWith(
                color: KaziColors.textPrimary,
              ),
            ),
            const SizedBox(height: 28),
            _Faq(
              question: t(context, 'help.q1'),
              answer: t(context, 'help.a1'),
            ),
            _Faq(
              question: t(context, 'help.q2'),
              answer: t(context, 'help.a2'),
            ),
            _Faq(
              question: t(context, 'help.q3'),
              answer: t(context, 'help.a3'),
            ),
            _Faq(
              question: t(context, 'help.q4'),
              answer: t(context, 'help.a4'),
            ),
            const SizedBox(height: 16),
            Text(t(context, 'help.contactUs'), style: KaziTextStyles.label),
            const SizedBox(height: 8),
            Text(
              t(context, 'help.emailPrompt'),
              style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => openContact(
                context,
                kind: ContactKind.email,
                value: supportEmail,
                emailSubject: t(context, 'help.emailSubject'),
                emailBody: t(context, 'help.emailBody'),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: KaziColors.grey15, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: KaziColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t(context, 'common.email'), style: KaziTextStyles.button),
                          Text(
                            supportEmail,
                            style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: KaziColors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: KaziTextStyles.button),
          const SizedBox(height: 6),
          Text(answer, style: KaziTextStyles.input),
        ],
      ),
    );
  }
}
