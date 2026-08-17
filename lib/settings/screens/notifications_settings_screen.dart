import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/settings/services/settings_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
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

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsStore.instance;

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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Notifications', style: KaziTextStyles.button),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Choose what you want to hear about.',
              style: KaziTextStyles.subtitle.copyWith(
                color: KaziColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _NotificationSwitch(
              title: 'Job updates',
              subtitle: 'Inquiries, accepts and rejects',
              value: settings.jobUpdates,
              onChanged: settings.setJobUpdates,
            ),
            _NotificationSwitch(
              title: 'Messages',
              subtitle: 'When someone contacts you',
              value: settings.messages,
              onChanged: settings.setMessages,
            ),
            _NotificationSwitch(
              title: 'Reminders',
              subtitle: 'Upcoming visits and follow-ups',
              value: settings.reminders,
              onChanged: settings.setReminders,
            ),
            _NotificationSwitch(
              title: 'Tips and offers',
              subtitle: 'Occasional news from Kazi',
              value: settings.marketing,
              onChanged: settings.setMarketing,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KaziColors.grey15, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KaziTextStyles.button),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: KaziColors.primary,
            activeTrackColor: KaziColors.primaryTint,
            inactiveThumbColor: KaziColors.grey,
            inactiveTrackColor: KaziColors.grey15,
          ),
        ],
      ),
    );
  }
}
