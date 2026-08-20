import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kazi/notifications/local_notifications.dart';
import 'package:kazi/settings/services/settings_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

class KaziNotifications {
  KaziNotifications._();

  static final KaziNotifications instance = KaziNotifications._();

  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool isForeground = true;

  Future<void> init() async {
    await initLocalNotifications();
  }

  Future<void> requestPermission() async {
    await requestLocalNotificationPermission();
  }

  void showJobUpdate({
    required String title,
    required String body,
  }) {
    if (!SettingsStore.instance.jobUpdates) return;

    if (kIsWeb || isForeground) {
      _showBanner(title, body);
    }
    if (!kIsWeb && !isForeground) {
      showLocalNotification(title: title, body: body);
    }
  }

  void _showBanner(String title, String body) {
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: KaziColors.primary,
          behavior: SnackBarBehavior.floating,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: KaziColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(color: KaziColors.white),
                ),
              ],
            ],
          ),
        ),
      );
  }
}
