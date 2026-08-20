import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

enum ContactKind { phone, email, whatsapp }

/// Opens mail, phone, or WhatsApp. On web, email uses Gmail in a new tab
/// because Chrome often ignores mailto: when no mail app is installed.
Future<void> openContact(
  BuildContext context, {
  required ContactKind kind,
  required String value,
  String? emailSubject,
  String? emailBody,
}) async {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;

  switch (kind) {
    case ContactKind.email:
      await _openEmail(
        context,
        email: trimmed,
        subject: emailSubject,
        body: emailBody,
      );
    case ContactKind.phone:
      await _openPhone(context, trimmed);
    case ContactKind.whatsapp:
      await _openWhatsApp(context, trimmed);
  }
}

Future<void> _openEmail(
  BuildContext context, {
  required String email,
  String? subject,
  String? body,
}) async {
  if (kIsWeb) {
    if (await _launch(_gmailCompose(email, subject: subject, body: body))) {
      return;
    }
  }
  if (await _launch(_mailto(email, subject: subject, body: body))) return;
  if (!context.mounted) return;
  await _showEmailOptions(
    context,
    email: email,
    subject: subject,
    body: body,
  );
}

Future<void> _openPhone(BuildContext context, String value) async {
  final tel = Uri.parse('tel:${_phoneUriNumber(value)}');
  if (!kIsWeb) {
    if (await _launch(tel)) return;
    if (context.mounted) await _copyFallback(context, value);
    return;
  }
  if (!context.mounted) return;
  await _showPhoneOptions(context, display: value, tel: tel);
}

Future<void> _openWhatsApp(BuildContext context, String value) async {
  final uri = Uri.parse('https://wa.me/${_whatsappDigits(value)}');
  if (await _launch(uri)) return;
  if (context.mounted) await _copyFallback(context, value);
}

Future<bool> _launch(Uri uri) async {
  try {
    return await launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (_) {
    return false;
  }
}

Uri _gmailCompose(String email, {String? subject, String? body}) {
  return Uri.https('mail.google.com', '/mail/', {
    'view': 'cm',
    'fs': '1',
    'tf': '1',
    'to': email,
    if (subject != null && subject.isNotEmpty) 'su': subject,
    if (body != null && body.isNotEmpty) 'body': body,
  });
}

Uri _mailto(String email, {String? subject, String? body}) {
  final parts = <String>[
    if (subject != null && subject.isNotEmpty)
      'subject=${Uri.encodeComponent(subject)}',
    if (body != null && body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
  ];
  return Uri(
    scheme: 'mailto',
    path: email,
    query: parts.isEmpty ? null : parts.join('&'),
  );
}

String _whatsappDigits(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0') && digits.length >= 9) {
    digits = '264${digits.substring(1)}';
  }
  return digits;
}

String _phoneUriNumber(String value) {
  final raw = value.trim();
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return digits;
  if (raw.startsWith('+')) return '+$digits';
  if (digits.startsWith('0') && digits.length >= 9) {
    return '+264${digits.substring(1)}';
  }
  return digits;
}

Future<void> _showEmailOptions(
  BuildContext context, {
  required String email,
  String? subject,
  String? body,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: KaziColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t(context, 'contact.howToReach'), style: KaziTextStyles.button),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.mail_outline, color: KaziColors.primary),
                title: Text(t(context, 'contact.openGmail'), style: KaziTextStyles.button),
                subtitle: Text(email, style: KaziTextStyles.subtitle.copyWith(fontSize: 13)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _launch(_gmailCompose(email, subject: subject, body: body));
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: KaziColors.primary),
                title: Text(t(context, 'contact.openMailApp'), style: KaziTextStyles.button),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _launch(_mailto(email, subject: subject, body: body));
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined, color: KaziColors.primary),
                title: Text(t(context, 'contact.copy'), style: KaziTextStyles.button),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  if (context.mounted) await _copyFallback(context, email);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showPhoneOptions(
  BuildContext context, {
  required String display,
  required Uri tel,
}) {
  final whatsapp = Uri.parse('https://wa.me/${_whatsappDigits(display)}');
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: KaziColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t(context, 'contact.howToReach'), style: KaziTextStyles.button),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: KaziColors.primary),
                title: Text(t(context, 'contact.call'), style: KaziTextStyles.button),
                subtitle: Text(display, style: KaziTextStyles.subtitle.copyWith(fontSize: 13)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _launch(tel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_outlined, color: KaziColors.primary),
                title: Text(t(context, 'common.whatsapp'), style: KaziTextStyles.button),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _launch(whatsapp);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined, color: KaziColors.primary),
                title: Text(t(context, 'contact.copy'), style: KaziTextStyles.button),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  if (context.mounted) await _copyFallback(context, display);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _copyFallback(BuildContext context, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(t(context, 'common.copied', {'value': value})),
      backgroundColor: KaziColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
