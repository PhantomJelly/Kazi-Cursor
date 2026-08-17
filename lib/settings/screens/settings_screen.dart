import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/settings/screens/delete_account_confirm_screen.dart';
import 'package:kazi/settings/screens/language_settings_screen.dart';
import 'package:kazi/settings/screens/logout_confirm_screen.dart';
import 'package:kazi/settings/screens/notifications_settings_screen.dart';
import 'package:kazi/settings/services/settings_store.dart';
import 'package:kazi/settings/widgets/settings_tile.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    SettingsStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    SettingsStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
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
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Settings', style: KaziTextStyles.heading),
              const SizedBox(height: 24),
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationsSettingsScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: SettingsStore.instance.language.label,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LanguageSettingsScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & support',
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About Kazi',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Log out',
                titleColor: KaziColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LogoutConfirmScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete account',
                titleColor: KaziColors.statusPending,
                iconColor: KaziColors.statusPending,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DeleteAccountConfirmScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
