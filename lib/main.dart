import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/screens/splash_screen.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/settings/services/settings_store.dart';
import 'package:kazi/shared/theme/kazi_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalAccountStore.instance.init();
  await InquiryStore.instance.init();
  await SettingsStore.instance.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const KaziApp());
}

class KaziApp extends StatelessWidget {
  const KaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi',
      debugShowCheckedModeBanner: false,
      theme: KaziTheme.light,
      home: const SplashScreen(),
    );
  }
}
