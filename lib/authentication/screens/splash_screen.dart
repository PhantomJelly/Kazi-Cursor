import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/app_shell/customer_app_shell.dart';
import 'package:kazi/app_shell/worker_app_shell.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/authentication/screens/sign_in_screen.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/authentication/widgets/kazi_logo.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

/// Full-blue splash with animated [KaziLogo].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final account = LocalAccountStore.instance.current;
    if (account != null) {
      LocalAccountStore.instance.restoreStores(account);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => account.role == UserRole.worker
              ? const WorkerAppShell()
              : const CustomerAppShell(),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: KaziColors.primary,
        systemNavigationBarColor: KaziColors.primary,
      ),
      child: const Scaffold(
        backgroundColor: KaziColors.primary,
        body: Center(
          child: KaziLogo(),
        ),
      ),
    );
  }
}
