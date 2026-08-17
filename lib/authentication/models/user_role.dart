enum UserRole {
  worker,
  customer,
}

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.worker:
        return 'Worker';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.worker:
        return 'Offer your skills and find jobs';
      case UserRole.customer:
        return 'Hire skilled workers near you';
    }
  }
}
