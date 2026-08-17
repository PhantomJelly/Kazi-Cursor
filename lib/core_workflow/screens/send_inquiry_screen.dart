import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/core_workflow/screens/inquiry_sent_screen.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/core_workflow/widgets/availability_calendar.dart';
import 'package:kazi/home_dashboard/models/demo_worker.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class SendInquiryScreen extends StatefulWidget {
  const SendInquiryScreen({super.key, required this.worker});

  final DemoWorker worker;

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
              onPrimary: KaziColors.grey,
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
        const SnackBar(
          content: Text('Please fill in every section before sending'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customer = CustomerProfileStore.instance.profile;
    if (customer == null) return;

    final inquiry = JobInquiry.fromForm(
      worker: widget.worker,
      customer: customer,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      occurredOn: _occurredOn!,
      timing: _timing!,
      freeDays: (_freeDays.toList()..sort()),
      isUrgent: _isUrgent!,
    );
    await InquiryStore.instance.add(inquiry);
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
          title: Text('Send inquiry', style: KaziTextStyles.button),
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
                        'Tell ${widget.worker.name.split(' ').first} about the job',
                        style: KaziTextStyles.heading.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.worker.trade.label,
                        style: KaziTextStyles.subtitle.copyWith(
                          color: KaziColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      KaziTextField(
                        controller: _titleController,
                        label: 'Issue title',
                        hint: 'e.g. Leaky tap',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),
                      Text('Project description', style: KaziTextStyles.label),
                      const SizedBox(height: 8),
                      Text(
                        'Describe the issue so the worker knows what to expect.',
                        style: KaziTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 6,
                        style: KaziTextStyles.input,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. The kitchen tap has been dripping and the cupboard below is getting wet...',
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
                      Text('When did it happen?', style: KaziTextStyles.label),
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
                                      ? 'Select the day the issue occurred'
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
                      Text('Urgency', style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => setState(() => _isUrgent = false),
                        child: _SelectTile(
                          selected: _isUrgent == false,
                          title: 'Not urgent',
                          subtitle: 'Can wait for a regular booking',
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
                                      'Urgent',
                                      style: KaziTextStyles.button.copyWith(
                                        color: KaziColors.urgent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Needs fixing in a few hours, or in the next day or 2.',
                                      style: KaziTextStyles.subtitle.copyWith(
                                        fontSize: 13,
                                        color: KaziColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You will need to pay more, as we would need the worker during odd hours.',
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
                      Text('Days you are free', style: KaziTextStyles.label),
                      const SizedBox(height: 8),
                      Text(
                        'Select multiple days as they might have a busy schedule.',
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
                  label: 'Send inquiry',
                  onPressed: _isComplete ? _send : null,
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
