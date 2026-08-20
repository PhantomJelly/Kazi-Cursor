import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/core_workflow/widgets/availability_calendar.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class CustomerInquiryDetailScreen extends StatefulWidget {
  const CustomerInquiryDetailScreen({super.key, required this.inquiryId});

  final String inquiryId;

  @override
  State<CustomerInquiryDetailScreen> createState() =>
      _CustomerInquiryDetailScreenState();
}

class _CustomerInquiryDetailScreenState
    extends State<CustomerInquiryDetailScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  Set<DateTime> _freeDays = {};
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  var _saving = false;

  JobInquiry? get _inquiry {
    final matches = InquiryStore.instance.inquiries.where(
      (item) => item.id == widget.inquiryId,
    );
    return matches.isEmpty ? null : matches.first;
  }

  @override
  void initState() {
    super.initState();
    InquiryStore.instance.addListener(_onStore);
    final inquiry = _inquiry;
    _title.text = inquiry?.title ?? '';
    _description.text = inquiry?.description ?? '';
    _freeDays = {
      for (final day in inquiry?.freeDays ?? const <DateTime>[])
        AvailabilityCalendar.dateOnly(day),
    };
    final focus = _freeDays.isNotEmpty
        ? (_freeDays.toList()..sort()).first
        : DateTime.now();
    _visibleMonth = DateTime(focus.year, focus.month);
  }

  @override
  void dispose() {
    InquiryStore.instance.removeListener(_onStore);
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final inquiry = _inquiry;
    if (inquiry == null) return;
    final description = _description.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.descriptionRequired')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_freeDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.needFreeDay')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await InquiryStore.instance.updateCustomerDetails(
        id: inquiry.id,
        description: description,
        freeDays: _freeDays.toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.saved')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.saveFailed')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: KaziColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            t(context, 'inquiry.detailTitle'),
            style: KaziTextStyles.button,
          ),
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
                      Text(
                        t(
                          context,
                          'inquiry.tellAbout',
                          {'name': inquiry.workerName.split(' ').first},
                        ),
                        style: KaziTextStyles.heading.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 28),

                      // Locked after send
                      _ReadOnlyBlock(
                        child: KaziTextField(
                          controller: _title,
                          label: t(context, 'inquiry.issueTitle'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Still editable
                      Text(
                        t(context, 'inquiry.projectDesc'),
                        style: KaziTextStyles.label,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t(context, 'inquiry.projectHint'),
                        style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _description,
                        maxLines: 6,
                        style: KaziTextStyles.input,
                        decoration: InputDecoration(
                          hintText: t(context, 'inquiry.projectHint'),
                          hintStyle: KaziTextStyles.input.copyWith(
                            color: KaziColors.textHint,
                          ),
                          filled: true,
                          fillColor: KaziColors.white,
                          contentPadding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 28),
                      _ReadOnlyBlock(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              t(context, 'inquiry.when'),
                              style: KaziTextStyles.label,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: KaziColors.grey15,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event_outlined,
                                    color: KaziColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      formatInquiryDate(inquiry.occurredOn),
                                      style: KaziTextStyles.input,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...IssueTiming.values.map((timing) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ChoiceTile(
                                  selected: inquiry.timing == timing,
                                  title: timing.label,
                                  subtitle: timing.description,
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            Text(
                              t(context, 'inquiry.urgency'),
                              style: KaziTextStyles.label,
                            ),
                            const SizedBox(height: 12),
                            _ChoiceTile(
                              selected: !inquiry.isUrgent,
                              title: t(context, 'inquiry.notUrgent'),
                              subtitle: t(context, 'inquiry.notUrgentSub'),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: inquiry.isUrgent
                                    ? const Color(0x14E53935)
                                    : KaziColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: KaziColors.urgent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    inquiry.isUrgent
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: KaziColors.urgent,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t(context, 'inquiry.isUrgent'),
                                          style: KaziTextStyles.button.copyWith(
                                            color: KaziColors.urgent,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t(context, 'inquiry.isUrgentSub'),
                                          style: KaziTextStyles.subtitle
                                              .copyWith(
                                            fontSize: 13,
                                            color: KaziColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        t(context, 'inquiry.daysFree'),
                        style: KaziTextStyles.label,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t(context, 'inquiry.daysFreeHint'),
                        style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      AvailabilityCalendar(
                        visibleMonth: _visibleMonth,
                        selectedDays: _freeDays,
                        onMonthChanged: (month) =>
                            setState(() => _visibleMonth = month),
                        onDayToggled: (day) {
                          setState(() {
                            if (_freeDays.contains(day)) {
                              _freeDays.remove(day);
                            } else {
                              _freeDays.add(day);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: KaziButton(
                  label: t(context, 'common.save'),
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyBlock extends StatelessWidget {
  const _ReadOnlyBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IgnorePointer(child: child),
        const SizedBox(height: 6),
        Text(
          t(context, 'inquiry.cantEdit'),
          style: KaziTextStyles.subtitle.copyWith(
            fontSize: 13,
            color: KaziColors.grey,
          ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.title,
    required this.subtitle,
  });

  final bool selected;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? KaziColors.primaryTint : KaziColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? KaziColors.primary : KaziColors.grey15,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? KaziColors.primary : KaziColors.grey,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KaziTextStyles.button),
                Text(
                  subtitle,
                  style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
