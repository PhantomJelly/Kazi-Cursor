import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/core_workflow/widgets/inquiry_calendar.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/contact_actions.dart';
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
        var showError = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                  Text(t(context, 'jobs.rejectWhy'), style: KaziTextStyles.button),
                  const SizedBox(height: 8),
                  Text(
                    t(context, 'jobs.rejectHint'),
                    style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    style: KaziTextStyles.input,
                    decoration: InputDecoration(
                      hintText: t(context, 'jobs.rejectHint'),
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
                        borderSide: BorderSide(
                          color: showError
                              ? KaziColors.statusPending
                              : KaziColors.grey15,
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
                  if (showError) ...[
                    const SizedBox(height: 8),
                    Text(
                      t(context, 'jobs.reasonRequired'),
                      style: KaziTextStyles.subtitle.copyWith(
                        color: KaziColors.statusPending,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  KaziButton(
                    label: t(context, 'jobs.sendRejection'),
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) {
                        setSheetState(() => showError = true);
                        return;
                      }
                      Navigator.of(sheetContext).pop(text);
                    },
                  ),
                ],
              ),
            );
          },
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
          return Scaffold(
            body: Center(child: Text(t(context, 'jobs.notFound'))),
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
              title: Text(t(context, 'jobs.detailTitle'), style: KaziTextStyles.button),
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
                                  t(context, 'common.urgent'),
                                  style: KaziTextStyles.button.copyWith(
                                    color: KaziColors.urgent,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            inquiry.status.label,
                            style: KaziTextStyles.button.copyWith(
                              color: inquiry.status.color,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            inquiry.customerName,
                            style: KaziTextStyles.heading,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            inquiry.customerLocation,
                            style: KaziTextStyles.subtitle.copyWith(
                              color: KaziColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            t(context, 'jobs.details'),
                            style: KaziTextStyles.label,
                          ),
                          const SizedBox(height: 8),
                          Text(inquiry.description, style: KaziTextStyles.input),
                          const SizedBox(height: 24),
                          InquiryCalendar(
                            occurredOn: inquiry.occurredOn,
                            availableDays: inquiry.freeDays.toSet(),
                          ),
                          if (inquiry.status == InquiryStatus.rejected &&
                              inquiry.rejectionReason != null) ...[
                            const SizedBox(height: 24),
                            _Detail(
                              label: t(context, 'jobs.rejectionReason'),
                              value: inquiry.rejectionReason!,
                            ),
                          ],
                          if (inquiry.status == InquiryStatus.accepted) ...[
                            const SizedBox(height: 8),
                            Text(t(context, 'jobs.customerContact'), style: KaziTextStyles.label),
                            const SizedBox(height: 8),
                            if (inquiry.customerEmail.isNotEmpty)
                              _Detail(
                                label: t(context, 'common.email'),
                                value: inquiry.customerEmail,
                                kind: ContactKind.email,
                              ),
                            if (inquiry.customerPhone.isNotEmpty)
                              _Detail(
                                label: t(context, 'common.phone'),
                                value: inquiry.customerPhone,
                                kind: ContactKind.phone,
                              ),
                            if (inquiry.customerWhatsapp.isNotEmpty)
                              _Detail(
                                label: t(context, 'common.whatsapp'),
                                value: inquiry.customerWhatsapp,
                                kind: ContactKind.whatsapp,
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
                            label: t(context, 'jobs.accept'),
                            onPressed: () async {
                              await InquiryStore.instance.accept(inquiry.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t(context, 'jobs.acceptedSnack')),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 12),
                          KaziButton(
                            label: t(context, 'jobs.reject'),
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
  const _Detail({required this.label, required this.value, this.kind});

  final String label;
  final String value;
  final ContactKind? kind;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KaziTextStyles.label),
        const SizedBox(height: 4),
        Text(value, style: KaziTextStyles.input),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: kind == null
          ? body
          : GestureDetector(
              onTap: () => openContact(context, kind: kind!, value: value),
              child: body,
            ),
    );
  }
}
