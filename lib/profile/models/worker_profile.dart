import 'package:kazi/authentication/models/sign_up_data.dart';
import 'package:kazi/profile/models/worker_certification.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/constants/work_experience_levels.dart';

class WorkerProfile {
  WorkerProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.town,
    required this.country,
    this.phone,
    this.whatsapp,
    this.specializations = const [],
    this.experience,
    this.profilePhotoPath,
    this.bio = '',
    this.portfolioPhotoPaths = const [],
    this.idDocumentPath,
    this.faceScanPath,
    this.certifications = const [],
  });

  static const int bioMinWords = 35;
  static const int totalSections = 4;

  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String town;
  final String country;
  final String? phone;
  final String? whatsapp;
  final List<TradeCategory> specializations;
  final WorkExperienceLevel? experience;
  final String? profilePhotoPath;
  final String bio;
  final List<String> portfolioPhotoPaths;
  final String? idDocumentPath;
  final String? faceScanPath;
  final List<WorkerCertification> certifications;

  String get fullName => '$firstName $lastName';

  bool get isGeneralInfoComplete =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      age >= 16 &&
      town.trim().isNotEmpty &&
      country.trim().isNotEmpty;

  bool get isWorkHistoryComplete =>
      specializations.isNotEmpty &&
      specializations.length <= 3 &&
      experience != null &&
      profilePhotoPath != null;

  int get bioWordCount =>
      bio.trim().isEmpty ? 0 : bio.trim().split(RegExp(r'\s+')).length;

  bool get isPortfolioComplete => bioWordCount >= bioMinWords;

  bool get isVerificationComplete =>
      idDocumentPath != null &&
      idDocumentPath!.isNotEmpty &&
      faceScanPath != null &&
      faceScanPath!.isNotEmpty;

  /// Bonus section — optional but shown on progress bar.
  bool get isCertificationsComplete =>
      certifications.isNotEmpty &&
      certifications.every((c) => c.documentPath.isNotEmpty);

  bool get isCertified => isCertificationsComplete;

  bool get isProfileComplete =>
      isGeneralInfoComplete &&
      isWorkHistoryComplete &&
      isPortfolioComplete &&
      isVerificationComplete;

  int get completedSectionCount => [
        isGeneralInfoComplete,
        isWorkHistoryComplete,
        isPortfolioComplete,
        isVerificationComplete,
      ].where((complete) => complete).length;

  double get progress => completedSectionCount / totalSections;

  WorkerProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    String? town,
    String? country,
    String? phone,
    String? whatsapp,
    List<TradeCategory>? specializations,
    WorkExperienceLevel? experience,
    String? profilePhotoPath,
    String? bio,
    List<String>? portfolioPhotoPaths,
    String? idDocumentPath,
    String? faceScanPath,
    List<WorkerCertification>? certifications,
  }) {
    return WorkerProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      age: age ?? this.age,
      town: town ?? this.town,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      specializations: specializations ?? this.specializations,
      experience: experience ?? this.experience,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      bio: bio ?? this.bio,
      portfolioPhotoPaths: portfolioPhotoPaths ?? this.portfolioPhotoPaths,
      idDocumentPath: idDocumentPath ?? this.idDocumentPath,
      faceScanPath: faceScanPath ?? this.faceScanPath,
      certifications: certifications ?? this.certifications,
    );
  }

  factory WorkerProfile.fromSignUp(SignUpData data) {
    return WorkerProfile(
      firstName: data.firstName ?? '',
      lastName: data.lastName ?? '',
      email: data.email,
      age: data.age ?? 0,
      town: data.town ?? '',
      country: data.country ?? '',
      phone: data.phone,
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'age': age,
        'town': town,
        'country': country,
        'phone': phone,
        'whatsapp': whatsapp,
        'specializations': specializations.map((s) => s.name).toList(),
        'experience': experience?.name,
        'profilePhotoPath': profilePhotoPath,
        'bio': bio,
        'portfolioPhotoPaths': portfolioPhotoPaths,
        'idDocumentPath': idDocumentPath,
        'faceScanPath': faceScanPath,
        'certifications': certifications.map((c) => c.toJson()).toList(),
      };

  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    return WorkerProfile(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      town: json['town'] as String? ?? '',
      country: json['country'] as String? ?? '',
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      specializations: (json['specializations'] as List<dynamic>? ?? [])
          .map((name) => TradeCategory.values.byName(name as String))
          .toList(),
      experience: json['experience'] == null
          ? null
          : WorkExperienceLevel.values.byName(json['experience'] as String),
      profilePhotoPath: json['profilePhotoPath'] as String?,
      bio: json['bio'] as String? ?? '',
      portfolioPhotoPaths: (json['portfolioPhotoPaths'] as List<dynamic>? ?? [])
          .map((path) => path as String)
          .toList(),
      idDocumentPath: json['idDocumentPath'] as String?,
      faceScanPath: json['faceScanPath'] as String?,
      certifications: (json['certifications'] as List<dynamic>? ?? [])
          .map((item) =>
              WorkerCertification.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
