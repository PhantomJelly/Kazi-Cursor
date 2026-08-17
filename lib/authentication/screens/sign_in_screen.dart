import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/screens/email_sign_in_screen.dart';
import 'package:kazi/authentication/screens/sign_up_email_screen.dart';
import 'package:kazi/authentication/services/auth_navigation.dart';
import 'package:kazi/authentication/services/google_auth_service.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/authentication/widgets/auth_divider.dart';
import 'package:kazi/authentication/widgets/auth_footer_link.dart';
import 'package:kazi/authentication/widgets/google_logo.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _googleAuthService = GoogleAuthService();
  bool _isGoogleLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final user = await _googleAuthService.signIn();
      if (!mounted) return;

      if (user == null) return;

      final names = (user.displayName ?? 'Demo User').trim().split(' ');
      final account = await LocalAccountStore.instance.signInOrCreateDummy(
        email: user.email,
        fromGoogle: true,
        firstName: names.first,
        lastName: names.length > 1 ? names.sublist(1).join(' ') : 'User',
      );
      if (!mounted) return;
      openAccountHome(context, account);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $error'),
          backgroundColor: KaziColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

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
                      Text('Welcome to', style: KaziTextStyles.welcome),
                      const SizedBox(height: 4),
                      Text('Kazi', style: KaziTextStyles.logo),
                      const SizedBox(height: 12),
                      Text(
                        'Work made simple.',
                        style: KaziTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                KaziButton(
                  label: 'Continue with Google',
                  variant: KaziButtonVariant.outline,
                  leading: const GoogleLogo(),
                  isLoading: _isGoogleLoading,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 20),
                const AuthDivider(),
                const SizedBox(height: 20),
                KaziButton(
                  label: 'Continue with Email',
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
                  prompt: "Don't have an account?",
                  actionLabel: 'Sign up',
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
