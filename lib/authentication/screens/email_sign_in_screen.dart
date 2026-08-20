import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/screens/forgot_password_screen.dart';
import 'package:kazi/authentication/services/auth_navigation.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'auth.enterEmailPassword')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
    });
    final account = await LocalAccountStore.instance.signInWithEmail(
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (account == null) {
      setState(() => _passwordError = t(context, 'auth.incorrectPassword'));
      return;
    }

    openAccountHome(context, account);
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t(context, 'auth.signInEmail'), style: KaziTextStyles.heading),
                const SizedBox(height: 12),
                Text(
                  t(context, 'auth.signInSubtitle'),
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
                  hint: t(context, 'auth.passwordHint'),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  errorText: _passwordError,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      t(context, 'auth.forgotPassword'),
                      style: KaziTextStyles.footerLink,
                    ),
                  ),
                ),
                const Spacer(),
                KaziButton(
                  label: t(context, 'auth.signIn'),
                  isLoading: _isLoading,
                  onPressed: _signIn,
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
