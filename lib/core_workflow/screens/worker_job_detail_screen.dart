import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';

class WorkerJobDetailScreen extends StatelessWidget {
  const WorkerJobDetailScreen({super.key, required this.inquiryId});

  final String inquiryId;

  JobInquiry? get _inquiry {
    final matches = InquiryStore.instance.inquiries.where(
      (item) => item.id == inquiryId,
    );
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _reject(BuildContext context, JobInquiry inquiry) async {
    final controller = TextEditingController();
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: KaziColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Why are you rejecting?', style: KaziTextStyles.button),
              const SizedBox(height: 8),
              Text(
                'The customer will see this explanation.',
                style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                style: KaziTextStyles.input,
                decoration: InputDecoration(
                  hintText: 'e.g. I am booked those days...',
                  hintStyle: KaziTextStyles.input.copyWith(
                    color: KaziColors.textHint,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: KaziColors.grey15,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: KaziColors.grey15,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: KaziColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              KaziButton(
                label: 'Send rejection',
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(sheetContext).pop(text);
                },
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return;
    await InquiryStore.instance.reject(inquiry.id, reason);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: InquiryStore.instance,
      builder: (context, _) {
        final inquiry = _inquiry;
        if (inquiry == null) {
          return const Scaffold(
            body: Center(child: Text('Inquiry not found')),
          );
        }

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
              title: Text('Job inquiry', style: KaziTextStyles.button),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  inquiry.title,
                                  style: KaziTextStyles.heading.copyWith(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              if (inquiry.isUrgent)
                                Text(
                                  'URGENT',
                                  style: KaziTextStyles.button.copyWith(
                                    color: KaziColors.urgent,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${inquiry.status.label}',
                            style: KaziTextStyles.button.copyWith(
                              color: inquiry.status.color,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _Detail(label: 'Customer', value: inquiry.customerName),
                          _Detail(
                            label: 'Location',
                            value: inquiry.customerLocation,
                          ),
                          _Detail(
                            label: 'Description',
                            value: inquiry.description,
                          ),
                          _Detail(
                            label: 'Occurred on',
                            value: formatInquiryDate(inquiry.occurredOn),
                          ),
                          _Detail(label: 'Timing', value: inquiry.timing.label),
                          _Detail(
                            label: 'Days free',
                            value: inquiry.freeDays
                                .map(formatInquiryDate)
                                .join(', '),
                          ),
                          if (inquiry.status == InquiryStatus.rejected &&
                              inquiry.rejectionReason != null)
                            _Detail(
                              label: 'Rejection reason',
                              value: inquiry.rejectionReason!,
                            ),
                          if (inquiry.status == InquiryStatus.accepted) ...[
                            const SizedBox(height: 8),
                            Text('Customer contact', style: KaziTextStyles.label),
                            const SizedBox(height: 8),
                            if (inquiry.customerEmail.isNotEmpty)
                              _Detail(label: 'Email', value: inquiry.customerEmail),
                            if (inquiry.customerPhone.isNotEmpty)
                              _Detail(label: 'Phone', value: inquiry.customerPhone),
                            if (inquiry.customerWhatsapp.isNotEmpty)
                              _Detail(
                                label: 'WhatsApp',
                                value: inquiry.customerWhatsapp,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (inquiry.status == InquiryStatus.pending)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          KaziButton(
                            label: 'Accept inquiry',
                            onPressed: () =>
                                InquiryStore.instance.accept(inquiry.id),
                          ),
                          const SizedBox(height: 12),
                          KaziButton(
                            label: 'Reject inquiry',
                            variant: KaziButtonVariant.outline,
                            onPressed: () => _reject(context, inquiry),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: KaziTextStyles.label),
          const SizedBox(height: 4),
          Text(value, style: KaziTextStyles.input),
        ],
      ),
    );
  }
}
