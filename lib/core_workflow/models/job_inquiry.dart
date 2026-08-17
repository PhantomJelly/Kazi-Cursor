import 'package:flutter/material.dart';
import 'package:kazi/home_dashboard/models/demo_worker.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

enum IssueTiming { firstTime, stillOccurring }

extension IssueTimingLabel on IssueTiming {
  String get label {
    switch (this) {
      case IssueTiming.firstTime:
        return 'First time';
      case IssueTiming.stillOccurring:
        return 'Still occurring';
    }
  }

  String get description {
    switch (this) {
      case IssueTiming.firstTime:
        return 'It happened once';
      case IssueTiming.stillOccurring:
        return 'It is still happening';
    }
  }
}

enum InquiryStatus { pending, accepted, rejected }

extension InquiryStatusStyle on InquiryStatus {
  String get label {
    switch (this) {
      case InquiryStatus.pending:
        return 'Pending';
      case InquiryStatus.accepted:
        return 'Accepted';
      case InquiryStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case InquiryStatus.pending:
        return KaziColors.statusPending;
      case InquiryStatus.accepted:
        return KaziColors.statusAccepted;
      case InquiryStatus.rejected:
        return KaziColors.statusPending;
    }
  }

  Color get borderColor {
    switch (this) {
      case InquiryStatus.pending:
        return KaziColors.grey15;
      case InquiryStatus.accepted:
        return KaziColors.statusAccepted;
      case InquiryStatus.rejected:
        return KaziColors.statusPending;
    }
  }
}

class JobInquiry {
  const JobInquiry({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.workerTown,
    required this.workerEmail,
    required this.workerPhone,
    required this.workerWhatsapp,
    required this.customerName,
    required this.customerTown,
    required this.customerCountry,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerWhatsapp,
    required this.title,
    required this.description,
    required this.occurredOn,
    required this.timing,
    required this.freeDays,
    required this.isUrgent,
    this.status = InquiryStatus.pending,
    this.rejectionReason,
  });

  final String id;
  final String workerId;
  final String workerName;
  final String workerTown;
  final String workerEmail;
  final String workerPhone;
  final String workerWhatsapp;
  final String customerName;
  final String customerTown;
  final String customerCountry;
  final String customerEmail;
  final String customerPhone;
  final String customerWhatsapp;
  final String title;
  final String description;
  final DateTime occurredOn;
  final IssueTiming timing;
  final List<DateTime> freeDays;
  final bool isUrgent;
  final InquiryStatus status;
  final String? rejectionReason;

  String get customerLocation => '$customerTown, $customerCountry';

  JobInquiry copyWith({
    InquiryStatus? status,
    String? rejectionReason,
  }) {
    return JobInquiry(
      id: id,
      workerId: workerId,
      workerName: workerName,
      workerTown: workerTown,
      workerEmail: workerEmail,
      workerPhone: workerPhone,
      workerWhatsapp: workerWhatsapp,
      customerName: customerName,
      customerTown: customerTown,
      customerCountry: customerCountry,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      customerWhatsapp: customerWhatsapp,
      title: title,
      description: description,
      occurredOn: occurredOn,
      timing: timing,
      freeDays: freeDays,
      isUrgent: isUrgent,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory JobInquiry.fromForm({
    required DemoWorker worker,
    required CustomerProfile customer,
    required String title,
    required String description,
    required DateTime occurredOn,
    required IssueTiming timing,
    required List<DateTime> freeDays,
    required bool isUrgent,
  }) {
    return JobInquiry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workerId: worker.id,
      workerName: worker.name,
      workerTown: worker.town,
      workerEmail: worker.email,
      workerPhone: worker.phone,
      workerWhatsapp: worker.whatsapp,
      customerName: customer.fullName,
      customerTown: customer.town,
      customerCountry: customer.country,
      customerEmail: customer.email,
      customerPhone: customer.phone ?? '',
      customerWhatsapp: customer.whatsapp ?? '',
      title: title,
      description: description,
      occurredOn: occurredOn,
      timing: timing,
      freeDays: freeDays,
      isUrgent: isUrgent,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workerId': workerId,
        'workerName': workerName,
        'workerTown': workerTown,
        'workerEmail': workerEmail,
        'workerPhone': workerPhone,
        'workerWhatsapp': workerWhatsapp,
        'customerName': customerName,
        'customerTown': customerTown,
        'customerCountry': customerCountry,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'customerWhatsapp': customerWhatsapp,
        'title': title,
        'description': description,
        'occurredOn': occurredOn.toIso8601String(),
        'timing': timing.name,
        'freeDays': freeDays.map((d) => d.toIso8601String()).toList(),
        'isUrgent': isUrgent,
        'status': status.name,
        'rejectionReason': rejectionReason,
      };

  factory JobInquiry.fromJson(Map<String, dynamic> json) {
    return JobInquiry(
      id: json['id'] as String? ?? '',
      workerId: json['workerId'] as String? ?? '',
      workerName: json['workerName'] as String? ?? '',
      workerTown: json['workerTown'] as String? ?? '',
      workerEmail: json['workerEmail'] as String? ?? '',
      workerPhone: json['workerPhone'] as String? ?? '',
      workerWhatsapp: json['workerWhatsapp'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerTown: json['customerTown'] as String? ?? '',
      customerCountry: json['customerCountry'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      customerWhatsapp: json['customerWhatsapp'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      occurredOn: DateTime.tryParse(json['occurredOn'] as String? ?? '') ??
          DateTime.now(),
      timing: IssueTiming.values.byName(
        json['timing'] as String? ?? IssueTiming.firstTime.name,
      ),
      freeDays: (json['freeDays'] as List<dynamic>? ?? [])
          .map((value) => DateTime.tryParse(value as String) ?? DateTime.now())
          .toList(),
      isUrgent: json['isUrgent'] as bool? ?? false,
      status: InquiryStatus.values.byName(
        json['status'] as String? ?? InquiryStatus.pending.name,
      ),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

String formatInquiryDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
