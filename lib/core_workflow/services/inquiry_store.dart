import 'package:flutter/foundation.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/notifications/kazi_notifications.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InquiryStore extends ChangeNotifier {
  InquiryStore._();

  static final InquiryStore instance = InquiryStore._();

  final List<JobInquiry> _inquiries = [];
  final Set<String> _silentIds = {};
  final Set<String> _notifiedKeys = {};
  UserRole? _viewerRole;
  String? _viewerEmail;
  RealtimeChannel? _channel;

  List<JobInquiry> get inquiries => List.unmodifiable(_inquiries);

  /// Jobs for the signed-in worker (not every inquiry the server returned).
  List<JobInquiry> get jobsForViewer {
    if (_viewerRole != UserRole.worker) {
      return inquiries;
    }
    final userId = _client.auth.currentUser?.id;
    final email = _viewerEmail ?? '';
    return _inquiries.where((item) {
      if (userId != null && item.workerId == userId) return true;
      if (email.isNotEmpty &&
          item.workerEmail.trim().toLowerCase() == email) {
        return true;
      }
      return false;
    }).toList();
  }

  SupabaseClient get _client => Supabase.instance.client;

  void bindViewer({UserRole? role, String? email}) {
    _viewerRole = role;
    _viewerEmail = email?.trim().toLowerCase();
    if (role == null) {
      stopRealtime();
    } else {
      startRealtime();
    }
  }

  List<JobInquiry> forCustomer(CustomerProfile profile) {
    final userId = _client.auth.currentUser?.id;
    final email = profile.email.trim().toLowerCase();
    final phone = (profile.phone ?? '').trim();
    return _inquiries.where((item) {
      if (userId != null && item.customerId == userId) return true;
      if (email.isNotEmpty &&
          item.customerEmail.trim().toLowerCase() == email) {
        return true;
      }
      if (phone.isNotEmpty && item.customerPhone.trim() == phone) {
        return true;
      }
      return false;
    }).toList();
  }

  bool hasPendingFor({
    required String workerId,
    required CustomerProfile customer,
  }) {
    return forCustomer(customer).any(
      (item) =>
          item.workerId == workerId && item.status == InquiryStatus.pending,
    );
  }

  List<JobInquiry> get acceptedForViewer => jobsForViewer
      .where((item) => item.status == InquiryStatus.accepted)
      .toList();

  Future<void> init() async {
    await refresh();
    await startRealtime();
  }

  /// Pull the latest rows. Call again from Jobs / Search when the tab is opened.
  Future<void> refresh() async {
    if (_client.auth.currentUser == null) {
      _inquiries.clear();
      notifyListeners();
      return;
    }
    try {
      final rows = await _client
          .from('inquiries')
          .select()
          .order('created_at', ascending: false);
      _inquiries
        ..clear()
        ..addAll(
          (rows as List<dynamic>).map(
            (item) => JobInquiry.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
      notifyListeners();
    } catch (_) {
      // Tables may not exist until schema.sql is run.
    }
  }

  Future<void> startRealtime() async {
    await stopRealtime();
    if (_client.auth.currentUser == null) return;
    try {
      final channel = _client.channel('inquiries-realtime');
      _channel = channel;
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'inquiries',
            callback: (payload) => _handleRealtime(
              PostgresChangeEvent.insert,
              payload.newRecord,
            ),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'inquiries',
            callback: (payload) => _handleRealtime(
              PostgresChangeEvent.update,
              payload.newRecord,
            ),
          )
          .subscribe();
    } catch (_) {
      // Realtime may be off until schema.sql is re-run.
    }
  }

  Future<void> stopRealtime() async {
    final channel = _channel;
    _channel = null;
    if (channel == null) return;
    try {
      await _client.removeChannel(channel);
    } catch (_) {}
  }

  // Send, accept, reject, and customer edits.
  Future<void> add(JobInquiry inquiry) async {
    final row = await _client.from('inquiries').insert(_toRow(inquiry)).select().single();
    final created = JobInquiry.fromJson(Map<String, dynamic>.from(row));
    _silentIds.add(created.id);
    _upsertLocal(created);
  }

  Future<void> accept(String id) async {
    _silentIds.add(id);
    await _client.from('inquiries').update({'status': 'accepted'}).eq('id', id);
    _updateLocal(id, (inquiry) => inquiry.copyWith(status: InquiryStatus.accepted));
  }

  Future<void> updateCustomerDetails({
    required String id,
    required String description,
    required List<DateTime> freeDays,
  }) async {
    final sorted = [...freeDays]..sort();
    await _client.from('inquiries').update({
      'description': description,
      'free_days': sorted.map(_dateOnly).toList(),
    }).eq('id', id);
    _updateLocal(
      id,
      (inquiry) => inquiry.copyWith(
        description: description,
        freeDays: sorted,
      ),
    );
  }

  Future<void> reject(String id, String reason) async {
    _silentIds.add(id);
    await _client.from('inquiries').update({
      'status': 'rejected',
      'rejection_reason': reason,
    }).eq('id', id);
    _updateLocal(
      id,
      (inquiry) => inquiry.copyWith(
        status: InquiryStatus.rejected,
        rejectionReason: reason,
      ),
    );
  }

  Future<void> syncCustomerContact({
    required String previousEmail,
    required String previousPhone,
    required CustomerProfile customer,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('inquiries').update({
      'customer_name': customer.fullName,
      'customer_town': customer.town,
      'customer_country': customer.country,
      'customer_email': customer.email,
      'customer_phone': customer.phone ?? '',
      'customer_whatsapp': customer.whatsapp ?? '',
    }).eq('customer_id', userId);
    await refresh();
  }

  Future<void> removeForUser({required String email, String? phone}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client.from('inquiries').delete().eq('customer_id', userId);
    }
    await refresh();
  }

  void _handleRealtime(
    PostgresChangeEvent event,
    Map<String, dynamic> record,
  ) {
    final inquiry = JobInquiry.fromJson(Map<String, dynamic>.from(record));
    _upsertLocal(inquiry);

    if (_silentIds.remove(inquiry.id)) return;

    final key = '${inquiry.id}:${inquiry.status.name}:${event.name}';
    if (!_notifiedKeys.add(key)) return;

    if (event == PostgresChangeEvent.insert &&
        _viewerRole == UserRole.worker &&
        _isOwnWorkerInquiry(inquiry)) {
      KaziNotifications.instance.showJobUpdate(
        title: inquiry.isUrgent
            ? tRaw('notify.urgentInquiry')
            : tRaw('notify.newInquiry'),
        body: '${inquiry.customerName} · ${inquiry.title}',
      );
    }

    if (event == PostgresChangeEvent.update &&
        _viewerRole == UserRole.customer &&
        _isOwnCustomerInquiry(inquiry)) {
      if (inquiry.status == InquiryStatus.accepted) {
        KaziNotifications.instance.showJobUpdate(
          title: tRaw('notify.accepted'),
          body: tRaw('notify.acceptedBody', {
            'name': inquiry.workerName,
            'title': inquiry.title,
          }),
        );
      } else if (inquiry.status == InquiryStatus.rejected) {
        KaziNotifications.instance.showJobUpdate(
          title: tRaw('notify.declined'),
          body: tRaw('notify.declinedBody', {
            'name': inquiry.workerName,
            'title': inquiry.title,
          }),
        );
      }
    }
  }

  bool _isOwnWorkerInquiry(JobInquiry inquiry) {
    final userId = _client.auth.currentUser?.id;
    if (userId != null && inquiry.workerId == userId) return true;
    final email = _viewerEmail ?? '';
    return email.isNotEmpty &&
        inquiry.workerEmail.trim().toLowerCase() == email;
  }

  bool _isOwnCustomerInquiry(JobInquiry inquiry) {
    final userId = _client.auth.currentUser?.id;
    if (userId != null && inquiry.customerId == userId) return true;
    final email = _viewerEmail ?? '';
    return email.isNotEmpty &&
        inquiry.customerEmail.trim().toLowerCase() == email;
  }

  void _upsertLocal(JobInquiry inquiry) {
    final index = _inquiries.indexWhere((item) => item.id == inquiry.id);
    if (index >= 0) {
      _inquiries[index] = inquiry;
    } else {
      _inquiries.insert(0, inquiry);
    }
    notifyListeners();
  }

  void _updateLocal(String id, JobInquiry Function(JobInquiry) transform) {
    final index = _inquiries.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _inquiries[index] = transform(_inquiries[index]);
    notifyListeners();
  }

  Map<String, dynamic> _toRow(JobInquiry inquiry) {
    return {
      'worker_id': inquiry.workerId,
      'worker_name': inquiry.workerName,
      'worker_town': inquiry.workerTown,
      'worker_email': inquiry.workerEmail,
      'worker_phone': inquiry.workerPhone,
      'worker_whatsapp': inquiry.workerWhatsapp,
      'customer_id': inquiry.customerId,
      'customer_name': inquiry.customerName,
      'customer_town': inquiry.customerTown,
      'customer_country': inquiry.customerCountry,
      'customer_email': inquiry.customerEmail,
      'customer_phone': inquiry.customerPhone,
      'customer_whatsapp': inquiry.customerWhatsapp,
      'title': inquiry.title,
      'description': inquiry.description,
      'occurred_on': _dateOnly(inquiry.occurredOn),
      'timing': inquiry.timing.name,
      'free_days': inquiry.freeDays.map(_dateOnly).toList(),
      'is_urgent': inquiry.isUrgent,
      'status': inquiry.status.name,
      'rejection_reason': inquiry.rejectionReason,
    };
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
