import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/app_shell/customer_app_shell.dart';
import 'package:kazi/app_shell/worker_app_shell.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/authentication/screens/sign_in_screen.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/shared/lottie/dotlottie.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:lottie/lottie.dart';

/// Full-blue splash that plays the Kazi Lottie intro once, then continues.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _asset = 'assets/lottie/kazi_splash.lottie';
  static const _fallbackTimeout = Duration(seconds: 6);

  late final AnimationController _controller;
  Timer? _fallback;
  var _didContinue = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _continue();
    });
    _fallback = Timer(_fallbackTimeout, _continue);
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (_didContinue || !mounted) return;
    _didContinue = true;
    _fallback?.cancel();

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
      child: Scaffold(
        backgroundColor: KaziColors.primary,
        body: Lottie.asset(
          _asset,
          controller: _controller,
          decoder: decodeDotLottie,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          delegates: LottieDelegates(
            textStyle: (font) => TextStyle(
              fontFamily: font.fontFamily,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }
}
