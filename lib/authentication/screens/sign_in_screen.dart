import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/screens/email_sign_in_screen.dart';
import 'package:kazi/authentication/screens/sign_up_email_screen.dart';
import 'package:kazi/authentication/widgets/auth_footer_link.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Text(t(context, 'auth.welcomeTo'), style: KaziTextStyles.welcome),
                      const SizedBox(height: 4),
                      Text('Kazi', style: KaziTextStyles.logo),
                      const SizedBox(height: 12),
                      Text(
                        t(context, 'auth.tagline'),
                        style: KaziTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                KaziButton(
                  label: t(context, 'auth.continueEmail'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const EmailSignInScreen(),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 2),
                AuthFooterLink(
                  prompt: t(context, 'auth.noAccount'),
                  actionLabel: t(context, 'auth.signUp'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SignUpEmailScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
