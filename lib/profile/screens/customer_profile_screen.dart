import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/screens/customer_inquiry_detail_screen.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/profile/screens/customer_edit_profile_screen.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/profile/widgets/profile_avatar.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/contact_actions.dart';

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
      return Scaffold(
        body: Center(child: Text(t(context, 'profile.noCustomer'))),
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
                    t(context, 'profile.yearsOld', {'age': '${profile.age}'}),
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: _openEdit,
                    child: Text(
                      t(context, 'common.editProfile'),
                      style: KaziTextStyles.footerLink,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(t(context, 'common.contact'), style: KaziTextStyles.label),
                const SizedBox(height: 12),
                if (profile.email.isNotEmpty)
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: t(context, 'common.email'),
                    value: profile.email,
                  ),
                if (profile.phone != null && profile.phone!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: t(context, 'common.phone'),
                    value: profile.phone!,
                  ),
                if (profile.whatsapp != null && profile.whatsapp!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.chat_outlined,
                    label: t(context, 'common.whatsapp'),
                    value: profile.whatsapp!,
                  ),
                if (profile.email.isEmpty &&
                    (profile.phone == null || profile.phone!.isEmpty) &&
                    (profile.whatsapp == null || profile.whatsapp!.isEmpty))
                  Text(
                    t(context, 'profile.contactEmpty'),
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                const SizedBox(height: 32),
                Text(t(context, 'profile.inquiries'), style: KaziTextStyles.label),
                const SizedBox(height: 12),
                if (InquiryStore.instance.forCustomer(profile).isEmpty)
                  Text(
                    t(context, 'profile.noInquiries'),
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                  )
                else
                  ...InquiryStore.instance
                      .forCustomer(profile)
                      .map((inquiry) => _InquiryTile(inquiry: inquiry)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InquiryTile extends StatefulWidget {
  const _InquiryTile({required this.inquiry});

  final JobInquiry inquiry;

  @override
  State<_InquiryTile> createState() => _InquiryTileState();
}

class _InquiryTileState extends State<_InquiryTile> {
  var _expanded = false;

  JobInquiry get inquiry => widget.inquiry;

  void _onTap() {
    // Pending: open the form. Accepted: expand contact. Rejected: stay on the card.
    if (inquiry.status == InquiryStatus.pending) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CustomerInquiryDetailScreen(
            inquiryId: inquiry.id,
          ),
        ),
      );
      return;
    }
    if (inquiry.status == InquiryStatus.accepted) {
      setState(() => _expanded = !_expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.topCenter,
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
                  inquiry.status.label,
                  style: KaziTextStyles.button.copyWith(
                    color: inquiry.status.color,
                    fontSize: 13,
                  ),
                ),
                if (inquiry.status == InquiryStatus.rejected) ...[
                  const SizedBox(height: 10),
                  Text(
                    t(context, 'jobs.rejectionReason'),
                    style: KaziTextStyles.label,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (inquiry.rejectionReason != null &&
                            inquiry.rejectionReason!.isNotEmpty)
                        ? inquiry.rejectionReason!
                        : t(context, 'jobs.noExplanation'),
                    style: KaziTextStyles.input,
                  ),
                ],
                if (inquiry.status == InquiryStatus.accepted && !_expanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      t(context, 'profile.tapForContact'),
                      style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                    ),
                  ),
                if (inquiry.status == InquiryStatus.accepted && _expanded) ...[
                  const SizedBox(height: 12),
                  Text(t(context, 'common.contact'), style: KaziTextStyles.label),
                  const SizedBox(height: 8),
                  if (inquiry.workerPhone.isNotEmpty)
                    _ContactOption(
                      icon: Icons.phone_outlined,
                      label: t(context, 'common.phone'),
                      value: inquiry.workerPhone,
                      kind: ContactKind.phone,
                    ),
                  if (inquiry.workerWhatsapp.isNotEmpty)
                    _ContactOption(
                      icon: Icons.chat_outlined,
                      label: t(context, 'common.whatsapp'),
                      value: inquiry.workerWhatsapp,
                      kind: ContactKind.whatsapp,
                    ),
                  if (inquiry.workerEmail.isNotEmpty)
                    _ContactOption(
                      icon: Icons.email_outlined,
                      label: t(context, 'common.email'),
                      value: inquiry.workerEmail,
                      kind: ContactKind.email,
                    ),
                ],
              ],
            ),
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
    required this.kind,
  });

  final IconData icon;
  final String label;
  final String value;
  final ContactKind kind;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => openContact(context, kind: kind, value: value),
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
