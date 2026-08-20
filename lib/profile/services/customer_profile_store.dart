import 'package:flutter/foundation.dart';
import 'package:kazi/authentication/models/sign_up_data.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/profile/models/customer_profile.dart';

/// In-memory customer profile store (frontend-only until backend exists).
class CustomerProfileStore extends ChangeNotifier {
  CustomerProfileStore._();

  static final CustomerProfileStore instance = CustomerProfileStore._();

  CustomerProfile? _profile;

  CustomerProfile? get profile => _profile;

  void load(CustomerProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }

  void initFromSignUp(SignUpData data) {
    _profile = CustomerProfile.fromSignUp(data);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required int age,
    required String town,
    required String country,
    required String email,
    String? phone,
    String? whatsapp,
    String? profilePhotoPath,
  }) async {
    if (_profile == null) return;
    final previousEmail = _profile!.email;
    final previousPhone = _profile!.phone ?? '';
    _profile = _profile!.copyWith(
      firstName: firstName,
      lastName: lastName,
      age: age,
      town: town,
      country: country,
      email: email,
      phone: phone,
      whatsapp: whatsapp,
      profilePhotoPath: profilePhotoPath ?? _profile!.profilePhotoPath,
    );
    notifyListeners();
    await InquiryStore.instance.syncCustomerContact(
      previousEmail: previousEmail,
      previousPhone: previousPhone,
      customer: _profile!,
    );
    await LocalAccountStore.instance.persistCurrent();
  }

  void recordContactedWorker(String workerId) {
    if (_profile == null) return;
    final ids = List<String>.of(_profile!.contactedWorkerIds)
      ..remove(workerId);
    ids.insert(0, workerId);
    _profile = _profile!.copyWith(contactedWorkerIds: ids);
    _save();
  }

  void _save() {
    notifyListeners();
    LocalAccountStore.instance.persistCurrent();
  }
}
