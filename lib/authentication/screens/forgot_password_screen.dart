import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(t(context, 'auth.enterAccountEmail'));
      return;
    }

    setState(() => _isLoading = true);
    final sent = await LocalAccountStore.instance.resetPassword(
      email: email,
      newPassword: '',
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = sent;
    });

    if (!sent) {
      _showMessage(t(context, 'auth.resetFailed'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                Text(t(context, 'auth.forgotTitle'), style: KaziTextStyles.heading),
                const SizedBox(height: 12),
                Text(
                  _sent
                      ? t(context, 'auth.forgotSent')
                      : t(context, 'auth.forgotSubtitle'),
                  style: KaziTextStyles.subtitle.copyWith(
                    color: KaziColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                if (!_sent)
                  KaziTextField(
                    controller: _emailController,
                    label: t(context, 'common.email'),
                    hint: t(context, 'hint.email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                const Spacer(),
                if (_sent)
                  KaziButton(
                    label: t(context, 'auth.backToSignIn'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                else
                  KaziButton(
                    label: t(context, 'auth.sendReset'),
                    isLoading: _isLoading,
                    onPressed: _sendReset,
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
