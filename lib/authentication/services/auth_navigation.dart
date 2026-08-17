import 'package:flutter/material.dart';
import 'package:kazi/app_shell/customer_app_shell.dart';
import 'package:kazi/app_shell/worker_app_shell.dart';
import 'package:kazi/authentication/models/local_account.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/authentication/services/local_account_store.dart';

void openAccountHome(BuildContext context, LocalAccount account) {
  LocalAccountStore.instance.restoreStores(account);
  final home = account.role == UserRole.worker
      ? const WorkerAppShell()
      : const CustomerAppShell();
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => home),
    (route) => false,
  );
}
