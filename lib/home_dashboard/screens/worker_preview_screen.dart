import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/screens/send_inquiry_screen.dart';
import 'package:kazi/home_dashboard/models/directory_worker.dart';
import 'package:kazi/home_dashboard/widgets/worker_photo.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';

class WorkerPreviewScreen extends StatelessWidget {
  const WorkerPreviewScreen({super.key, required this.worker});

  final DirectoryWorker worker;

  void _openInquiry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SendInquiryScreen(worker: worker),
      ),
    );
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
        appBar: AppBar(
          backgroundColor: KaziColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: WorkerPhoto(
                          photoUrl: worker.photoUrl,
                          radius: 56,
                          heroTag: worker.heroTag,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        worker.name,
                        style: KaziTextStyles.heading,
                        textAlign: TextAlign.center,
                      ),
                      if (worker.isCertified) ...[
                        const SizedBox(height: 12),
                        ...worker.certifications.map(
                          (cert) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: KaziColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${cert.title} · ${cert.issuer}',
                                    style: KaziTextStyles.subtitle.copyWith(
                                      fontSize: 13,
                                      color: KaziColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (worker.tradeLabel.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          worker.tradeLabel,
                          style: KaziTextStyles.button,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        [
                          worker.town,
                          worker.country,
                        ].where((part) => part.isNotEmpty).join(', '),
                        style: KaziTextStyles.subtitle.copyWith(
                          color: KaziColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (worker.experienceLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          worker.experienceLabel,
                          style: KaziTextStyles.subtitle.copyWith(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (worker.bio.trim().isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          t(context, 'inquiry.aboutWorker'),
                          style: KaziTextStyles.label,
                        ),
                        const SizedBox(height: 8),
                        Text(worker.bio, style: KaziTextStyles.input),
                      ],
                      if (worker.portfolioPhotoUrls.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          t(context, 'inquiry.pastJobs'),
                          style: KaziTextStyles.label,
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: worker.portfolioPhotoUrls.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                worker.portfolioPhotoUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: KaziColors.grey8,
                                  child: const Icon(
                                    Icons.photo_outlined,
                                    color: KaziColors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: KaziButton(
                  label: t(context, 'search.sendInquiry'),
                  onPressed: () => _openInquiry(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
