import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/profile/models/worker_profile.dart';
import 'package:kazi/profile/screens/worker_profile_sections_screen.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/profile/widgets/profile_avatar.dart';
import 'package:kazi/profile/widgets/profile_progress_card.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/constants/work_experience_levels.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/contact_actions.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WorkerProfileStore.instance.addListener(_onProfileChanged);
    InquiryStore.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    WorkerProfileStore.instance.removeListener(_onProfileChanged);
    InquiryStore.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() => setState(() {});

  void _openSections() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WorkerProfileSectionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = WorkerProfileStore.instance.profile;
    if (profile == null) {
      return Scaffold(
        body: Center(child: Text(t(context, 'profile.noWorker'))),
      );
    }

    final isComplete = profile.isProfileComplete;
    final professions = profile.specializations.map((c) => c.label).join(' · ');

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
                if (!isComplete) ...[
                  ProfileProgressCard(
                    progress: profile.progress,
                    completedSections: profile.completedSectionCount,
                    totalSections: WorkerProfile.totalSections,
                    bonusComplete: profile.isCertificationsComplete,
                    onTap: _openSections,
                  ),
                  const SizedBox(height: 28),
                ],
                Center(child: ProfileAvatar(path: profile.profilePhotoPath)),
                const SizedBox(height: 16),
                _NameRow(
                  name: profile.fullName,
                  showStar: profile.isCertified,
                ),
                const SizedBox(height: 6),
                Text(
                  '${profile.town}, ${profile.country}',
                  style: KaziTextStyles.subtitle.copyWith(
                    color: KaziColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (profile.specializations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    professions,
                    style: KaziTextStyles.subtitle.copyWith(
                      fontSize: 15,
                      color: KaziColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (profile.experience != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.experience!.label,
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: _openSections,
                    child: Text(
                      t(context, 'common.editProfile'),
                      style: KaziTextStyles.footerLink,
                    ),
                  ),
                ),
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _InfoSection(title: t(context, 'common.about'), value: profile.bio),
                ],
                if (profile.certifications.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(t(context, 'profile.certifications'), style: KaziTextStyles.label),
                  const SizedBox(height: 12),
                  ...profile.certifications.map(
                    (cert) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: KaziColors.grey15,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.school_outlined,
                              color: KaziColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cert.title, style: KaziTextStyles.button),
                                Text(
                                  cert.issuer,
                                  style: KaziTextStyles.subtitle
                                      .copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(t(context, 'common.contact'), style: KaziTextStyles.label),
                const SizedBox(height: 12),
                if (profile.email.isNotEmpty)
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: t(context, 'common.email'),
                    value: profile.email,
                    kind: ContactKind.email,
                  ),
                if (profile.phone != null && profile.phone!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: t(context, 'common.phone'),
                    value: profile.phone!,
                    kind: ContactKind.phone,
                  ),
                if (profile.whatsapp != null && profile.whatsapp!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.chat_outlined,
                    label: t(context, 'common.whatsapp'),
                    value: profile.whatsapp!,
                    kind: ContactKind.whatsapp,
                  ),
                if (profile.email.isEmpty &&
                    (profile.phone == null || profile.phone!.isEmpty) &&
                    (profile.whatsapp == null || profile.whatsapp!.isEmpty))
                  Text(
                    t(context, 'profile.contactEmpty'),
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                if (InquiryStore.instance.acceptedForViewer.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(t(context, 'profile.acceptedClients'), style: KaziTextStyles.label),
                  const SizedBox(height: 12),
                  ...InquiryStore.instance.acceptedForViewer.map(
                    (inquiry) => _AcceptedClientTile(inquiry: inquiry),
                  ),
                ],
                if (profile.portfolioPhotoPaths.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(t(context, 'inquiry.pastJobs'), style: KaziTextStyles.label),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: profile.portfolioPhotoPaths.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final path = profile.portfolioPhotoPaths[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image(
                          image: platform_image.imageProviderFromPath(path),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
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

class _AcceptedClientTile extends StatelessWidget {
  const _AcceptedClientTile({required this.inquiry});

  final JobInquiry inquiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KaziColors.grey15, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(inquiry.title, style: KaziTextStyles.button),
          const SizedBox(height: 4),
          Text(
            inquiry.customerName,
            style: KaziTextStyles.subtitle.copyWith(
              fontSize: 13,
              color: KaziColors.textPrimary,
            ),
          ),
          Text(
            inquiry.customerLocation,
            style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (inquiry.customerEmail.isNotEmpty)
            _ContactRow(
              icon: Icons.email_outlined,
              label: t(context, 'common.email'),
              value: inquiry.customerEmail,
              kind: ContactKind.email,
            ),
          if (inquiry.customerPhone.isNotEmpty)
            _ContactRow(
              icon: Icons.phone_outlined,
              label: t(context, 'common.phone'),
              value: inquiry.customerPhone,
              kind: ContactKind.phone,
            ),
          if (inquiry.customerWhatsapp.isNotEmpty)
            _ContactRow(
              icon: Icons.chat_outlined,
              label: t(context, 'common.whatsapp'),
              value: inquiry.customerWhatsapp,
              kind: ContactKind.whatsapp,
            ),
        ],
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name, required this.showStar});

  final String name;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            name,
            style: KaziTextStyles.heading,
            textAlign: TextAlign.center,
          ),
        ),
        if (showStar) ...[
          const SizedBox(width: 8),
          const Icon(Icons.star, color: KaziColors.primary, size: 22),
        ],
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: KaziTextStyles.label),
        const SizedBox(height: 6),
        Text(value, style: KaziTextStyles.input),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
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
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => openContact(context, kind: kind, value: value),
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
            const Icon(Icons.chevron_right_rounded, color: KaziColors.grey),
          ],
        ),
      ),
    );
  }
}
