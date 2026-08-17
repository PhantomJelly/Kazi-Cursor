import 'package:kazi/authentication/models/user_role.dart';

class SignUpData {
  const SignUpData({
    this.email = '',
    this.phone,
    this.fromGoogle = false,
    this.fromPhone = false,
    this.firstName,
    this.lastName,
    this.age,
    this.town,
    this.country,
    this.role,
    this.password,
  });

  final String email;
  final String? phone;
  final bool fromGoogle;
  final bool fromPhone;
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? town;
  final String? country;
  final UserRole? role;
  final String? password;

  SignUpData copyWith({
    String? email,
    String? phone,
    bool? fromGoogle,
    bool? fromPhone,
    String? firstName,
    String? lastName,
    int? age,
    String? town,
    String? country,
    UserRole? role,
    String? password,
  }) {
    return SignUpData(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fromGoogle: fromGoogle ?? this.fromGoogle,
      fromPhone: fromPhone ?? this.fromPhone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      town: town ?? this.town,
      country: country ?? this.country,
      role: role ?? this.role,
      password: password ?? this.password,
    );
  }
}
