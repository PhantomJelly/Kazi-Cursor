import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/services/auth_navigation.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';

class DeleteAccountConfirmScreen extends StatefulWidget {
  const DeleteAccountConfirmScreen({super.key});

  @override
  State<DeleteAccountConfirmScreen> createState() =>
      _DeleteAccountConfirmScreenState();
}

class _DeleteAccountConfirmScreenState
    extends State<DeleteAccountConfirmScreen> {
  var _busy = false;

  void _confirm() {
    if (_busy) return;
    setState(() => _busy = true);
    goToSignIn(context);
    unawaited(_deleteInBackground());
  }

  Future<void> _deleteInBackground() async {
    final account = LocalAccountStore.instance.current;
    try {
      await InquiryStore.instance.removeForUser(
        email: account?.email ?? account?.customerProfile?.email ?? '',
        phone: account?.phone ?? account?.customerProfile?.phone,
      );
    } catch (_) {}
    try {
      await LocalAccountStore.instance.deleteCurrentAccount();
    } catch (_) {}
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t(context, 'settings.deleteTitle'), style: KaziTextStyles.heading),
                const SizedBox(height: 12),
                Text(
                  t(context, 'settings.deleteBody'),
                  style: KaziTextStyles.subtitle.copyWith(
                    color: KaziColors.textPrimary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: KaziColors.statusPending,
                      foregroundColor: KaziColors.white,
                      disabledBackgroundColor: KaziColors.statusPending,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: KaziColors.white,
                            ),
                          )
                        : Text(
                            t(context, 'settings.delete'),
                            style: KaziTextStyles.button.copyWith(
                              color: KaziColors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                KaziButton(
                  label: t(context, 'common.cancel'),
                  variant: KaziButtonVariant.outline,
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
