import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:kazi/profile/models/worker_profile.dart';

class LocalAccount {
  LocalAccount({
    required this.role,
    this.email = '',
    this.phone,
    this.password = '',
    this.fromGoogle = false,
    this.fromPhone = false,
    this.workerProfile,
    this.customerProfile,
  });

  final String email;
  final String? phone;
  final String password;
  final bool fromGoogle;
  final bool fromPhone;
  final UserRole role;
  WorkerProfile? workerProfile;
  CustomerProfile? customerProfile;

  String get id {
    if (email.trim().isNotEmpty) return email.trim().toLowerCase();
    return phone?.trim() ?? '';
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'password': password,
        'fromGoogle': fromGoogle,
        'fromPhone': fromPhone,
        'role': role.name,
        'workerProfile': workerProfile?.toJson(),
        'customerProfile': customerProfile?.toJson(),
      };

  factory LocalAccount.fromJson(Map<String, dynamic> json) {
    return LocalAccount(
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      password: json['password'] as String? ?? '',
      fromGoogle: json['fromGoogle'] as bool? ?? false,
      fromPhone: json['fromPhone'] as bool? ?? false,
      role: UserRole.values.byName(json['role'] as String? ?? 'customer'),
      workerProfile: json['workerProfile'] == null
          ? null
          : WorkerProfile.fromJson(
              Map<String, dynamic>.from(json['workerProfile'] as Map),
            ),
      customerProfile: json['customerProfile'] == null
          ? null
          : CustomerProfile.fromJson(
              Map<String, dynamic>.from(json['customerProfile'] as Map),
            ),
    );
  }
}
