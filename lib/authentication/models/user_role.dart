import 'package:kazi/l10n/kazi_l10n.dart';

enum UserRole {
  worker,
  customer,
}

extension UserRoleLabel on UserRole {
  String get label => tRaw('role.$name');

  String get description => tRaw('role.$name.desc');
}
