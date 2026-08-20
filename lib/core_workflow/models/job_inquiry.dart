import 'package:flutter/material.dart';
import 'package:kazi/home_dashboard/models/directory_worker.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

enum IssueTiming { firstTime, stillOccurring }

extension IssueTimingLabel on IssueTiming {
  String get label => tRaw('timing.$name');

  String get description => tRaw('timing.$name.desc');
}

enum InquiryStatus { pending, accepted, rejected }

extension InquiryStatusStyle on InquiryStatus {
  String get label => tRaw('status.$name');

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
    this.customerId = '',
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
  final String customerId;
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
    String? customerName,
    String? customerTown,
    String? customerCountry,
    String? customerEmail,
    String? customerPhone,
    String? customerWhatsapp,
    String? description,
    List<DateTime>? freeDays,
  }) {
    return JobInquiry(
      id: id,
      workerId: workerId,
      workerName: workerName,
      workerTown: workerTown,
      workerEmail: workerEmail,
      workerPhone: workerPhone,
      workerWhatsapp: workerWhatsapp,
      customerId: customerId,
      customerName: customerName ?? this.customerName,
      customerTown: customerTown ?? this.customerTown,
      customerCountry: customerCountry ?? this.customerCountry,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerWhatsapp: customerWhatsapp ?? this.customerWhatsapp,
      title: title,
      description: description ?? this.description,
      occurredOn: occurredOn,
      timing: timing,
      freeDays: freeDays ?? this.freeDays,
      isUrgent: isUrgent,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory JobInquiry.fromForm({
    required DirectoryWorker worker,
    required CustomerProfile customer,
    required String customerId,
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
      customerId: customerId,
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
        'customerId': customerId,
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
      workerId:
          json['workerId'] as String? ?? json['worker_id'] as String? ?? '',
      workerName:
          json['workerName'] as String? ?? json['worker_name'] as String? ?? '',
      workerTown:
          json['workerTown'] as String? ?? json['worker_town'] as String? ?? '',
      workerEmail: json['workerEmail'] as String? ??
          json['worker_email'] as String? ??
          '',
      workerPhone: json['workerPhone'] as String? ??
          json['worker_phone'] as String? ??
          '',
      workerWhatsapp: json['workerWhatsapp'] as String? ??
          json['worker_whatsapp'] as String? ??
          '',
      customerId:
          json['customerId'] as String? ?? json['customer_id'] as String? ?? '',
      customerName: json['customerName'] as String? ??
          json['customer_name'] as String? ??
          '',
      customerTown: json['customerTown'] as String? ??
          json['customer_town'] as String? ??
          '',
      customerCountry: json['customerCountry'] as String? ??
          json['customer_country'] as String? ??
          '',
      customerEmail: json['customerEmail'] as String? ??
          json['customer_email'] as String? ??
          '',
      customerPhone: json['customerPhone'] as String? ??
          json['customer_phone'] as String? ??
          '',
      customerWhatsapp: json['customerWhatsapp'] as String? ??
          json['customer_whatsapp'] as String? ??
          '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      occurredOn: DateTime.tryParse(
            json['occurredOn'] as String? ?? json['occurred_on'] as String? ?? '',
          ) ??
          DateTime.now(),
      timing: IssueTiming.values.byName(
        json['timing'] as String? ?? IssueTiming.firstTime.name,
      ),
      freeDays: (json['freeDays'] as List<dynamic>? ??
              json['free_days'] as List<dynamic>? ??
              [])
          .map((value) => DateTime.tryParse(value as String) ?? DateTime.now())
          .toList(),
      isUrgent: json['isUrgent'] as bool? ?? json['is_urgent'] as bool? ?? false,
      status: InquiryStatus.values.byName(
        json['status'] as String? ?? InquiryStatus.pending.name,
      ),
      rejectionReason: json['rejectionReason'] as String? ??
          json['rejection_reason'] as String?,
    );
  }
}

String formatInquiryDate(DateTime date) {
  return '${date.day} ${tRaw('month.${date.month}')} ${date.year}';
}
