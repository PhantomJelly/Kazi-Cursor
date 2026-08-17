import 'dart:convert';

import 'package:kazi/authentication/models/local_account.dart';
import 'package:kazi/authentication/models/sign_up_data.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local frontend accounts until a backend exists.
class LocalAccountStore {
  LocalAccountStore._();

  static final LocalAccountStore instance = LocalAccountStore._();

  static const _accountsKey = 'kazi.accounts';
  static const _sessionKey = 'kazi.session';

  SharedPreferences? _prefs;
  final Map<String, LocalAccount> _accounts = {};
  String? _currentId;

  LocalAccount? get current =>
      _currentId == null ? null : _accounts[_currentId];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_accountsKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _accounts[entry.key] = LocalAccount.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }
    _currentId = _prefs!.getString(_sessionKey);
  }

  Future<bool> register(SignUpData data) async {
    final account = LocalAccount(
      email: data.email,
      phone: data.phone,
      password: data.password ?? '',
      fromGoogle: data.fromGoogle,
      fromPhone: data.fromPhone,
      role: data.role!,
      workerProfile: data.role == UserRole.worker
          ? WorkerProfileStore.instance.profile
          : null,
      customerProfile: data.role == UserRole.customer
          ? CustomerProfileStore.instance.profile
          : null,
    );
    if (account.id.isEmpty) return false;
    if (_accounts.containsKey(account.id)) return false;

    _accounts[account.id] = account;
    _currentId = account.id;
    await _flush();
    return true;
  }

  Future<LocalAccount?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null) return null;
    if (account.fromGoogle && account.password.isEmpty) return null;
    if (account.password != password) return null;
    _currentId = account.id;
    await _flushSession();
    restoreStores(account);
    return account;
  }

  Future<LocalAccount?> signInWithGoogle(String email) async {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null) return null;
    _currentId = account.id;
    await _flushSession();
    restoreStores(account);
    return account;
  }

  /// Sign-in buttons skip onboarding. Restore a saved account, or create a
  /// dummy customer profile for frontend demo data.
  Future<LocalAccount> signInOrCreateDummy({
    required String email,
    String? password,
    bool fromGoogle = false,
    String? firstName,
    String? lastName,
  }) async {
    final key = email.trim().toLowerCase();
    final existing = _accounts[key];
    if (existing != null) {
      _currentId = existing.id;
      await _flushSession();
      restoreStores(existing);
      return existing;
    }

    final data = SignUpData(
      email: email.trim(),
      password: password,
      fromGoogle: fromGoogle,
      firstName: (firstName != null && firstName.trim().isNotEmpty)
          ? firstName.trim()
          : 'Demo',
      lastName: (lastName != null && lastName.trim().isNotEmpty)
          ? lastName.trim()
          : 'User',
      age: 28,
      town: 'Windhoek',
      country: 'Namibia',
      role: UserRole.customer,
    );
    CustomerProfileStore.instance.initFromSignUp(data);
    await register(data);
    return current!;
  }

  bool exists(String emailOrPhone) {
    final key = emailOrPhone.trim().toLowerCase();
    return _accounts.containsKey(key) || _accounts.containsKey(emailOrPhone.trim());
  }

  void restoreStores(LocalAccount account) {
    WorkerProfileStore.instance.clear();
    CustomerProfileStore.instance.clear();
    if (account.role == UserRole.worker && account.workerProfile != null) {
      WorkerProfileStore.instance.load(account.workerProfile!);
    }
    if (account.role == UserRole.customer && account.customerProfile != null) {
      CustomerProfileStore.instance.load(account.customerProfile!);
    }
  }

  Future<void> persistCurrent() async {
    final account = current;
    if (account == null) return;
    account.workerProfile = WorkerProfileStore.instance.profile;
    account.customerProfile = CustomerProfileStore.instance.profile;
    _accounts[account.id] = account;
    await _flush();
  }

  Future<void> signOut() async {
    _currentId = null;
    WorkerProfileStore.instance.clear();
    CustomerProfileStore.instance.clear();
    await _prefs?.remove(_sessionKey);
  }

  Future<void> deleteCurrentAccount() async {
    final id = _currentId;
    WorkerProfileStore.instance.clear();
    CustomerProfileStore.instance.clear();
    _currentId = null;
    if (id != null) {
      _accounts.remove(id);
    }
    await _prefs?.remove(_sessionKey);
    await _flush();
  }

  Future<void> _flush() async {
    final encoded = jsonEncode(
      _accounts.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs?.setString(_accountsKey, encoded);
    await _flushSession();
  }

  Future<void> _flushSession() async {
    if (_currentId == null) {
      await _prefs?.remove(_sessionKey);
    } else {
      await _prefs?.setString(_sessionKey, _currentId!);
    }
  }
}
