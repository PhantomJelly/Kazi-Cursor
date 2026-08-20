import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/models/sign_up_data.dart';
import 'package:kazi/authentication/screens/sign_up_profile_screen.dart';
import 'package:kazi/authentication/services/auth_navigation.dart';
import 'package:kazi/authentication/services/google_auth_service.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/authentication/widgets/auth_footer_link.dart';
import 'package:kazi/authentication/widgets/google_logo.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class SignUpEmailScreen extends StatefulWidget {
  const SignUpEmailScreen({super.key});

  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _googleAuthService = GoogleAuthService();
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
  }

  void _continueWithEmail() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'auth.validEmail')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'auth.passwordMin')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'auth.passwordsMismatch')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (LocalAccountStore.instance.exists(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'auth.emailExists')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SignUpProfileScreen(
          signUpData: SignUpData(email: email, password: password),
        ),
      ),
    );
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final user = await _googleAuthService.signIn();
      if (!mounted || user == null) return;

      if (user.idToken == null || user.idToken!.isEmpty) {
        throw Exception('Google did not return an ID token.');
      }

      await LocalAccountStore.instance.signInWithGoogleToken(
        idToken: user.idToken!,
        accessToken: user.accessToken,
      );
      if (!mounted) return;

      final existing = LocalAccountStore.instance.current;
      if (!mounted) return;
      if (existing != null) {
        openAccountHome(context, existing);
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SignUpProfileScreen(
            signUpData: SignUpData(
              email: user.email,
              fromGoogle: true,
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is GoogleNotConfiguredException
                ? t(context, 'auth.googleNotReady')
                : t(context, 'auth.googleSignUpFailed', {'error': '$error'}),
          ),
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
        appBar: AppBar(
          backgroundColor: KaziColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: KaziColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t(context, 'auth.createAccount'),
                        style: KaziTextStyles.heading,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t(context, 'auth.signUpSubtitle'),
                        style: KaziTextStyles.subtitle.copyWith(
                          color: KaziColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      KaziTextField(
                        controller: _emailController,
                        label: t(context, 'common.email'),
                        hint: t(context, 'hint.email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      KaziTextField(
                        controller: _passwordController,
                        label: t(context, 'common.password'),
                        hint: t(context, 'auth.createPassword'),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: KaziColors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      KaziTextField(
                        controller: _confirmPasswordController,
                        label: t(context, 'auth.confirmPassword'),
                        hint: t(context, 'auth.reenterPassword'),
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: KaziColors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      KaziButton(
                        label: t(context, 'common.continue'),
                        onPressed: _continueWithEmail,
                      ),
                      const SizedBox(height: 16),
                      KaziButton(
                        label: t(context, 'auth.useGoogle'),
                        variant: KaziButtonVariant.outline,
                        leading: const GoogleLogo(),
                        isLoading: _isGoogleLoading,
                        onPressed: _signUpWithGoogle,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: AuthFooterLink(
                  prompt: t(context, 'auth.alreadyAccount'),
                  actionLabel: t(context, 'auth.signIn'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
