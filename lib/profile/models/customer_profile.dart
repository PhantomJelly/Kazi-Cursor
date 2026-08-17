import 'package:kazi/authentication/models/sign_up_data.dart';

class CustomerProfile {
  CustomerProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.town,
    required this.country,
    this.phone,
    this.whatsapp,
    this.profilePhotoPath,
    this.contactedWorkerIds = const [],
  });

  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String town;
  final String country;
  final String? phone;
  final String? whatsapp;
  final String? profilePhotoPath;
  final List<String> contactedWorkerIds;

  String get fullName => '$firstName $lastName';

  /// Customer profiles are complete after sign-up.
  bool get isProfileComplete => true;

  CustomerProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    String? town,
    String? country,
    String? phone,
    String? whatsapp,
    String? profilePhotoPath,
    List<String>? contactedWorkerIds,
  }) {
    return CustomerProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      age: age ?? this.age,
      town: town ?? this.town,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      contactedWorkerIds: contactedWorkerIds ?? this.contactedWorkerIds,
    );
  }

  factory CustomerProfile.fromSignUp(SignUpData data) {
    return CustomerProfile(
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
        'profilePhotoPath': profilePhotoPath,
        'contactedWorkerIds': contactedWorkerIds,
      };

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      town: json['town'] as String? ?? '',
      country: json['country'] as String? ?? '',
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      profilePhotoPath: json['profilePhotoPath'] as String?,
      contactedWorkerIds: (json['contactedWorkerIds'] as List<dynamic>? ?? [])
          .map((id) => id as String)
          .toList(),
    );
  }
}
