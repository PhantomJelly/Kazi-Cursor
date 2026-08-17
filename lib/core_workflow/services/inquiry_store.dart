import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kazi/core_workflow/models/job_inquiry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared inquiry inbox for the frontend demo (visible to any signed-in worker).
class InquiryStore extends ChangeNotifier {
  InquiryStore._();

  static final InquiryStore instance = InquiryStore._();
  static const _storageKey = 'kazi.inquiries';

  SharedPreferences? _prefs;
  final List<JobInquiry> _inquiries = [];

  List<JobInquiry> get inquiries => List.unmodifiable(_inquiries);

  List<JobInquiry> forCustomer(String email) {
    final key = email.trim().toLowerCase();
    return _inquiries
        .where((item) => item.customerEmail.trim().toLowerCase() == key)
        .toList();
  }

  List<JobInquiry> get accepted => _inquiries
      .where((item) => item.status == InquiryStatus.accepted)
      .toList();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _inquiries
      ..clear()
      ..addAll(
        decoded.map(
          (item) => JobInquiry.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
  }

  Future<void> add(JobInquiry inquiry) async {
    _inquiries.insert(0, inquiry);
    notifyListeners();
    await _flush();
  }

  Future<void> accept(String id) async {
    _update(id, (inquiry) => inquiry.copyWith(status: InquiryStatus.accepted));
  }

  Future<void> reject(String id, String reason) async {
    _update(
      id,
      (inquiry) => inquiry.copyWith(
        status: InquiryStatus.rejected,
        rejectionReason: reason,
      ),
    );
  }

  void _update(String id, JobInquiry Function(JobInquiry) transform) {
    final index = _inquiries.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _inquiries[index] = transform(_inquiries[index]);
    notifyListeners();
    _flush();
  }

  Future<void> _flush() async {
    await _prefs?.setString(
      _storageKey,
      jsonEncode(_inquiries.map((item) => item.toJson()).toList()),
    );
  }
}
