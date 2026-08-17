import 'package:flutter/foundation.dart';
import 'package:kazi/authentication/models/sign_up_data.dart';
import 'package:kazi/authentication/services/local_account_store.dart';
import 'package:kazi/profile/models/worker_certification.dart';
import 'package:kazi/profile/models/worker_profile.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/constants/work_experience_levels.dart';

/// In-memory worker profile store (frontend-only until backend exists).
class WorkerProfileStore extends ChangeNotifier {
  WorkerProfileStore._();

  static final WorkerProfileStore instance = WorkerProfileStore._();

  WorkerProfile? _profile;

  WorkerProfile? get profile => _profile;

  void load(WorkerProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }

  void initFromSignUp(SignUpData data) {
    _profile = WorkerProfile.fromSignUp(data);
    notifyListeners();
  }

  void updateGeneralInfo({
    required String firstName,
    required String lastName,
    required int age,
    required String town,
    required String country,
    required String email,
    String? phone,
    String? whatsapp,
  }) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      firstName: firstName,
      lastName: lastName,
      age: age,
      town: town,
      country: country,
      email: email,
      phone: phone,
      whatsapp: whatsapp,
    );
    _save();
  }

  void updateWorkHistory({
    required List<TradeCategory> specializations,
    WorkExperienceLevel? experience,
    String? profilePhotoPath,
  }) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      specializations: specializations,
      experience: experience ?? _profile!.experience,
      profilePhotoPath: profilePhotoPath ?? _profile!.profilePhotoPath,
    );
    _save();
  }

  void updatePortfolio({
    required String bio,
    required List<String> portfolioPhotoPaths,
  }) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      bio: bio,
      portfolioPhotoPaths: portfolioPhotoPaths,
    );
    _save();
  }

  void updateCertifications(List<WorkerCertification> certifications) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(certifications: certifications);
    _save();
  }

  void updateVerification({
    String? idDocumentPath,
    String? faceScanPath,
  }) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      idDocumentPath: idDocumentPath ?? _profile!.idDocumentPath,
      faceScanPath: faceScanPath ?? _profile!.faceScanPath,
    );
    _save();
  }

  void _save() {
    notifyListeners();
    LocalAccountStore.instance.persistCurrent();
  }
}
