import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/profile/models/worker_profile.dart';
import 'package:kazi/profile/screens/worker_certifications_screen.dart';
import 'package:kazi/profile/screens/worker_general_info_screen.dart';
import 'package:kazi/profile/screens/worker_portfolio_screen.dart';
import 'package:kazi/profile/screens/worker_verification_screen.dart';
import 'package:kazi/profile/screens/worker_work_history_screen.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/profile/widgets/profile_progress_bar.dart';
import 'package:kazi/profile/widgets/profile_section_tile.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

/// Profile sections list — completion checklist or edit profile.
class WorkerProfileSectionsScreen extends StatefulWidget {
  const WorkerProfileSectionsScreen({super.key});

  @override
  State<WorkerProfileSectionsScreen> createState() =>
      _WorkerProfileSectionsScreenState();
}

class _WorkerProfileSectionsScreenState
    extends State<WorkerProfileSectionsScreen> {
  @override
  void initState() {
    super.initState();
    WorkerProfileStore.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    WorkerProfileStore.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final profile = WorkerProfileStore.instance.profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('No worker profile found')),
      );
    }

    final isComplete = profile.isProfileComplete;

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
          title: Text(
            isComplete ? 'Edit profile' : 'Complete your profile',
            style: KaziTextStyles.button,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isComplete) ...[
                  ProfileProgressBar(
                    progress: profile.progress,
                    completedSections: profile.completedSectionCount,
                    totalSections: WorkerProfile.totalSections,
                    bonusComplete: profile.isCertificationsComplete,
                  ),
                  const SizedBox(height: 28),
                ],
                _buildSectionTiles(context, profile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTiles(BuildContext context, WorkerProfile profile) {
    return Column(
      children: [
        ProfileSectionTile(
          title: 'General information',
          subtitle: 'Name, location, phone and WhatsApp',
          isComplete: profile.isGeneralInfoComplete,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => WorkerGeneralInfoScreen(profile: profile),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ProfileSectionTile(
          title: 'Work history',
          subtitle: 'Specialisation, experience and photo',
          isComplete: profile.isWorkHistoryComplete,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WorkerWorkHistoryScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ProfileSectionTile(
          title: 'Work portfolio',
          subtitle: 'Bio and photos of past jobs',
          isComplete: profile.isPortfolioComplete,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WorkerPortfolioScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ProfileSectionTile(
          title: 'Verification',
          subtitle: 'Upload ID or passport and scan your face',
          isComplete: profile.isVerificationComplete,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WorkerVerificationScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ProfileSectionTile(
          title: 'Certifications',
          subtitle: 'Attach certificates to earn Certified badge',
          isComplete: profile.isCertificationsComplete,
          isBonus: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WorkerCertificationsScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
