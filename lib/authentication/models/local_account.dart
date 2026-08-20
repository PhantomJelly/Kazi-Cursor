import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:kazi/profile/models/worker_profile.dart';

class LocalAccount {
  LocalAccount({
    required this.id,
    required this.role,
    this.email = '',
    this.phone,
    this.password = '',
    this.fromGoogle = false,
    this.workerProfile,
    this.customerProfile,
  });

  final String id;
  final String email;
  final String? phone;
  final String password;
  final bool fromGoogle;
  final UserRole role;
  WorkerProfile? workerProfile;
  CustomerProfile? customerProfile;
}
