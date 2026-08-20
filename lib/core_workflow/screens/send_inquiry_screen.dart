import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/screens/inquiry_sent_screen.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/core_workflow/widgets/availability_calendar.dart';
import 'package:kazi/home_dashboard/models/directory_worker.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class SendInquiryScreen extends StatefulWidget {
  const SendInquiryScreen({super.key, required this.worker});

  final DirectoryWorker worker;

  @override
  State<SendInquiryScreen> createState() => _SendInquiryScreenState();
}

class _SendInquiryScreenState extends State<SendInquiryScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _occurredOn;
  IssueTiming? _timing;
  bool? _isUrgent;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final Set<DateTime> _freeDays = {};
  var _sending = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _isComplete =>
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _occurredOn != null &&
      _timing != null &&
      _isUrgent != null &&
      _freeDays.isNotEmpty;

  Future<void> _pickOccurredOn() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredOn ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: KaziColors.primary,
              onPrimary: KaziColors.white,
              onSurface: KaziColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _occurredOn = AvailabilityCalendar.dateOnly(picked));
    }
  }

  Future<void> _send() async {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.fillEvery')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customer = CustomerProfileStore.instance.profile;
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.completeProfile')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (InquiryStore.instance.hasPendingFor(
      workerId: widget.worker.id,
      customer: customer,
    )) {
      final continueAnyway = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: KaziColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(t(context, 'inquiry.alreadyTitle'), style: KaziTextStyles.button),
            content: Text(
              t(context, 'inquiry.alreadyBody'),
              style: KaziTextStyles.input,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(t(context, 'common.cancel'), style: KaziTextStyles.footerLink),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(t(context, 'inquiry.sendAnyway'), style: KaziTextStyles.footerLink),
              ),
            ],
          );
        },
      );
      if (continueAnyway != true || !mounted) return;
    }

    final customerId = LocalAccountStore.instance.current?.id ?? '';
    if (customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.signInAgain')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _sending = true);
    final inquiry = JobInquiry.fromForm(
      worker: widget.worker,
      customer: customer,
      customerId: customerId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      occurredOn: _occurredOn!,
      timing: _timing!,
      freeDays: (_freeDays.toList()..sort()),
      isUrgent: _isUrgent!,
    );
    try {
      await InquiryStore.instance.add(inquiry);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'inquiry.sendFailed')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    CustomerProfileStore.instance.recordContactedWorker(widget.worker.id);

    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const InquirySentScreen()),
    );
    if (mounted) Navigator.of(context).pop();
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
          title: Text(t(context, 'inquiry.sendTitle'), style: KaziTextStyles.button),
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
                          {'name': widget.worker.name.split(' ').first},
                        ),
                        style: KaziTextStyles.heading.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      if (widget.worker.tradeLabel.isNotEmpty)
                        Text(
                          widget.worker.tradeLabel,
                          style: KaziTextStyles.subtitle.copyWith(
                            color: KaziColors.textPrimary,
                          ),
                        ),
                      const SizedBox(height: 28),

                      // Title
                      KaziTextField(
                        controller: _titleController,
                        label: t(context, 'inquiry.issueTitle'),
                        hint: t(context, 'inquiry.issueHint'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(t(context, 'inquiry.projectDesc'), style: KaziTextStyles.label),
                      const SizedBox(height: 8),
                      Text(
                        t(context, 'inquiry.projectHint'),
                        style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
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

                      // When it happened
                      Text(t(context, 'inquiry.when'), style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickOccurredOn,
                        child: Container(
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
                                  _occurredOn == null
                                      ? t(context, 'inquiry.when')
                                      : formatInquiryDate(_occurredOn!),
                                  style: KaziTextStyles.input.copyWith(
                                    color: _occurredOn == null
                                        ? KaziColors.textHint
                                        : KaziColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...IssueTiming.values.map((timing) {
                        final selected = _timing == timing;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _timing = timing),
                            child: _SelectTile(
                              selected: selected,
                              title: timing.label,
                              subtitle: timing.description,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Urgency
                      Text(t(context, 'inquiry.urgency'), style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => setState(() => _isUrgent = false),
                        child: _SelectTile(
                          selected: _isUrgent == false,
                          title: t(context, 'inquiry.notUrgent'),
                          subtitle: t(context, 'inquiry.notUrgentSub'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => setState(() => _isUrgent = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: _isUrgent == true
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
                                _isUrgent == true
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: KaziColors.urgent,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style: KaziTextStyles.subtitle.copyWith(
                                        fontSize: 13,
                                        color: KaziColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t(context, 'inquiry.urgentPay'),
                                      style: KaziTextStyles.subtitle.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Days the customer is free
                      Text(t(context, 'inquiry.daysFree'), style: KaziTextStyles.label),
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
                      if (_freeDays.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${_freeDays.length} day${_freeDays.length == 1 ? '' : 's'} selected',
                          style: KaziTextStyles.subtitle.copyWith(
                            fontSize: 13,
                            color: KaziColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: KaziButton(
                  label: t(context, 'inquiry.sendTitle'),
                  isLoading: _sending,
                  onPressed: _isComplete && !_sending ? _send : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
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
