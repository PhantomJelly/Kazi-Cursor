import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/home_dashboard/models/demo_worker.dart';
import 'package:kazi/home_dashboard/screens/worker_preview_screen.dart';
import 'package:kazi/profile/screens/customer_edit_profile_screen.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/profile/widgets/profile_avatar.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    CustomerProfileStore.instance.addListener(_onProfileChanged);
    InquiryStore.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    CustomerProfileStore.instance.removeListener(_onProfileChanged);
    InquiryStore.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() => setState(() {});

  void _openEdit() {
    final profile = CustomerProfileStore.instance.profile;
    if (profile == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerEditProfileScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = CustomerProfileStore.instance.profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('No customer profile found')),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: Scaffold(
        backgroundColor: KaziColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ProfileAvatar(
                    path: profile.profilePhotoPath,
                    radius: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.fullName,
                  style: KaziTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '${profile.town}, ${profile.country}',
                  style: KaziTextStyles.subtitle.copyWith(
                    color: KaziColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (profile.age > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${profile.age} years old',
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: _openEdit,
                    child: Text(
                      'Edit profile',
                      style: KaziTextStyles.footerLink,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Contact', style: KaziTextStyles.label),
                const SizedBox(height: 12),
                if (profile.email.isNotEmpty)
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: profile.email,
                  ),
                if (profile.phone != null && profile.phone!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: profile.phone!,
                  ),
                if (profile.whatsapp != null && profile.whatsapp!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    value: profile.whatsapp!,
                  ),
                if (profile.email.isEmpty &&
                    (profile.phone == null || profile.phone!.isEmpty) &&
                    (profile.whatsapp == null || profile.whatsapp!.isEmpty))
                  Text(
                    'No contact details yet',
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                const SizedBox(height: 32),
                Text('Inquiries', style: KaziTextStyles.label),
                const SizedBox(height: 12),
                if (InquiryStore.instance.forCustomer(profile.email).isEmpty)
                  Text(
                    'Inquiries you send will show up here.',
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                  )
                else
                  ...InquiryStore.instance
                      .forCustomer(profile.email)
                      .map((inquiry) => _InquiryTile(inquiry: inquiry)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  const _InquiryTile({required this.inquiry});

  final JobInquiry inquiry;

  @override
  Widget build(BuildContext context) {
    final worker = demoWorkerById(inquiry.workerId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: worker == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkerPreviewScreen(worker: worker),
                  ),
                );
              },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: inquiry.status.borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(inquiry.title, style: KaziTextStyles.button),
              const SizedBox(height: 4),
              Text(
                inquiry.workerName,
                style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${inquiry.status.label}',
                style: KaziTextStyles.button.copyWith(
                  color: inquiry.status.color,
                  fontSize: 13,
                ),
              ),
              if (inquiry.status == InquiryStatus.rejected) ...[
                const SizedBox(height: 10),
                Text('Reason', style: KaziTextStyles.label),
                const SizedBox(height: 4),
                Text(
                  (inquiry.rejectionReason != null &&
                          inquiry.rejectionReason!.isNotEmpty)
                      ? inquiry.rejectionReason!
                      : 'No explanation given.',
                  style: KaziTextStyles.input,
                ),
              ],
              if (inquiry.status == InquiryStatus.accepted) ...[
                const SizedBox(height: 12),
                Text('Contact', style: KaziTextStyles.label),
                const SizedBox(height: 8),
                if (inquiry.workerPhone.isNotEmpty)
                  _ContactOption(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: inquiry.workerPhone,
                  ),
                if (inquiry.workerWhatsapp.isNotEmpty)
                  _ContactOption(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    value: inquiry.workerWhatsapp,
                  ),
                if (inquiry.workerEmail.isNotEmpty)
                  _ContactOption(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: inquiry.workerEmail,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label · $value'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KaziColors.grey15, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: KaziColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: KaziTextStyles.button),
                    Text(
                      value,
                      style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: KaziColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: KaziColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                ),
                Text(value, style: KaziTextStyles.input),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
