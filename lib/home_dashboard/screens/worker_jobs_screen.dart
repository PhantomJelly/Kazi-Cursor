import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/screens/worker_job_detail_screen.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';

class WorkerJobsScreen extends StatefulWidget {
  const WorkerJobsScreen({super.key});

  @override
  State<WorkerJobsScreen> createState() => _WorkerJobsScreenState();
}

class _WorkerJobsScreenState extends State<WorkerJobsScreen> {
  @override
  void initState() {
    super.initState();
    InquiryStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    InquiryStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final jobs = InquiryStore.instance.inquiries;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: Scaffold(
        backgroundColor: KaziColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jobs', style: KaziTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  'Inquiries from customers.',
                  style: KaziTextStyles.subtitle.copyWith(
                    color: KaziColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: jobs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.work_outline,
                                size: 48,
                                color: KaziColors.grey30,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No inquiries yet',
                                style: KaziTextStyles.button.copyWith(
                                  color: KaziColors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'When a customer sends an inquiry, it will show up here.',
                                style: KaziTextStyles.subtitle.copyWith(
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: jobs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _JobTile(inquiry: jobs[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.inquiry});

  final JobInquiry inquiry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WorkerJobDetailScreen(inquiryId: inquiry.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: inquiry.isUrgent ? KaziColors.urgent : KaziColors.grey15,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(inquiry.title, style: KaziTextStyles.button),
                ),
                if (inquiry.isUrgent)
                  Text(
                    'URGENT',
                    style: KaziTextStyles.button.copyWith(
                      color: KaziColors.urgent,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              inquiry.customerName,
              style: KaziTextStyles.input,
            ),
            Text(
              inquiry.customerLocation,
              style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
