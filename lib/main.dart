import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kazi/authentication/screens/splash_screen.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/notifications/kazi_notifications.dart';
import 'package:kazi/settings/models/app_language.dart';
import 'package:kazi/settings/services/settings_store.dart';
import 'package:kazi/shared/theme/kazi_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Session, language, alerts, then live inquiries.
  await LocalAccountStore.instance.init();
  await SettingsStore.instance.init();
  await KaziNotifications.instance.init();
  await InquiryStore.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const KaziApp());
}

class KaziApp extends StatefulWidget {
  const KaziApp({super.key});

  @override
  State<KaziApp> createState() => _KaziAppState();
}

class _KaziAppState extends State<KaziApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    KaziNotifications.instance.isForeground =
        state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      InquiryStore.instance.refresh();
      InquiryStore.instance.startRealtime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsStore.instance,
      builder: (context, _) {
        final language = SettingsStore.instance.language;
        return MaterialApp(
          title: 'Kazi',
          debugShowCheckedModeBanner: false,
          theme: KaziTheme.light,
          navigatorKey: _navigatorKey,
          scaffoldMessengerKey: KaziNotifications.instance.messengerKey,
          locale: language.locale,
          supportedLocales: AppLanguage.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return KaziL10nScope(
              language: language,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
