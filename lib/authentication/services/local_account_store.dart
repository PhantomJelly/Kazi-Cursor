import 'package:kazi/authentication/models/local_account.dart';
import 'package:kazi/authentication/models/sign_up_data.dart';
import 'package:kazi/authentication/models/user_role.dart';
import 'package:kazi/authentication/utils/phone_number.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/profile/models/customer_profile.dart';
import 'package:kazi/profile/models/worker_certification.dart';
import 'package:kazi/profile/models/worker_profile.dart';
import 'package:kazi/profile/services/customer_profile_store.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/constants/work_experience_levels.dart';
import 'package:kazi/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalAccountStore {
  LocalAccountStore._();

  static final LocalAccountStore instance = LocalAccountStore._();

  static const _demoGooglePassword = 'KaziDemo123!';

  LocalAccount? _current;

  LocalAccount? get current => _current;

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    final session = _client.auth.currentSession;
    if (session != null) {
      _current = await _loadAccount(session.user.id);
      if (_current != null) restoreStores(_current!);
    }
  }

  Future<bool> register(SignUpData data) async {
    try {
      final userId = await _ensureAuthUser(data);
      if (userId == null) return false;

      if (data.role == UserRole.worker) {
        WorkerProfileStore.instance.initFromSignUp(data);
      } else {
        CustomerProfileStore.instance.initFromSignUp(data);
      }

      await _upsertProfiles(
        userId: userId,
        role: data.role!,
        email: data.email,
        phone: data.phone,
      );

      _current = await _loadAccount(userId);
      if (_current != null) restoreStores(_current!);
      await InquiryStore.instance.refresh();
      return _current != null;
    } on AuthException {
      return false;
    } on PostgrestException {
      await _client.auth.signOut();
      _current = null;
      return false;
    }
  }

  Future<LocalAccount?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final userId = result.user?.id;
      if (userId == null) return null;
      _current = await _loadAccount(userId);
      if (_current == null) {
        await _client.auth.signOut();
        return null;
      }
      restoreStores(_current!);
      await InquiryStore.instance.refresh();
      return _current;
    } on AuthException {
      return null;
    }
  }

  Future<LocalAccount?> signInWithGoogleToken({
    required String idToken,
    String? accessToken,
  }) async {
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    _current = await _loadAccount(userId);
    if (_current != null) {
      restoreStores(_current!);
      await InquiryStore.instance.refresh();
    }
    return _current;
  }

  Future<LocalAccount?> signInWithGoogle(String email) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    _current = await _loadAccount(userId);
    if (_current != null) restoreStores(_current!);
    await InquiryStore.instance.refresh();
    return _current;
  }

  Future<LocalAccount> completeGoogleSignIn({
    required String idToken,
    String? accessToken,
    String? firstName,
    String? lastName,
  }) async {
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Google sign-in did not create a session.');
    }

    final existing = await _loadAccount(user.id);
    if (existing != null) {
      _current = existing;
      restoreStores(existing);
      await InquiryStore.instance.refresh();
      return existing;
    }

    final data = SignUpData(
      email: user.email ?? '',
      fromGoogle: true,
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
    await _upsertProfiles(
      userId: user.id,
      role: UserRole.customer,
      email: data.email,
    );
    _current = await _loadAccount(user.id);
    if (_current == null) {
      throw Exception('Could not create your profile.');
    }
    restoreStores(_current!);
    await InquiryStore.instance.refresh();
    return _current!;
  }

  Future<LocalAccount> signInOrCreateDummy({
    required String email,
    String? password,
    bool fromGoogle = false,
    String? firstName,
    String? lastName,
  }) async {
    final resolvedPassword = password ?? _demoGooglePassword;
    final existing = await signInWithEmail(
      email: email,
      password: resolvedPassword,
    );
    if (existing != null) return existing;

    final data = SignUpData(
      email: email.trim(),
      password: resolvedPassword,
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
    final created = await register(data);
    if (!created || _current == null) {
      throw Exception('Could not create account. Check your connection.');
    }
    return _current!;
  }

  bool exists(String emailOrPhone) {
    // Auth users cannot be listed from the client. Duplicates are handled
    // when sign-up talks to Supabase.
    return false;
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
    InquiryStore.instance.bindViewer(
      role: account.role,
      email: account.email,
    );
  }

  Future<void> persistCurrent() async {
    final account = _current;
    if (account == null) return;
    try {
      await _upsertProfiles(
        userId: account.id,
        role: account.role,
        email: account.email,
        phone: account.phone,
      );
      _current = LocalAccount(
        id: account.id,
        email: account.email,
        phone: account.role == UserRole.worker
            ? WorkerProfileStore.instance.profile?.phone
            : CustomerProfileStore.instance.profile?.phone,
        role: account.role,
        fromGoogle: account.fromGoogle,
        workerProfile: WorkerProfileStore.instance.profile,
        customerProfile: CustomerProfileStore.instance.profile,
      );
    } catch (_) {
      // Keep the in-memory profile even if the network write fails.
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return true;
    } on AuthException {
      return false;
    }
  }

  Future<void> signOut() async {
    _current = null;
    WorkerProfileStore.instance.clear();
    CustomerProfileStore.instance.clear();
    InquiryStore.instance.bindViewer();
    try {
      await _client.auth.signOut();
    } catch (_) {}
    await InquiryStore.instance.refresh();
  }

  Future<void> deleteCurrentAccount() async {
    try {
      await _client.rpc('delete_own_account');
    } catch (_) {
      // Fall through to local sign-out even if the RPC is not installed yet.
    }
    await signOut();
  }

  Future<String?> _ensureAuthUser(SignUpData data) async {
    final existingId = _client.auth.currentUser?.id;
    if (existingId != null) return existingId;

    final email = _authEmail(data);
    final password = _authPassword(data);
    if (email.isEmpty || password.length < 6) return null;

    try {
      final result = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (result.session == null) {
        await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
      return _client.auth.currentUser?.id;
    } on AuthException catch (error) {
      final alreadyRegistered = error.message.toLowerCase().contains(
            'already',
          );
      if (!alreadyRegistered) rethrow;
      final result = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return result.user?.id;
    }
  }

  String _authEmail(SignUpData data) {
    return data.email.trim().toLowerCase();
  }

  String _authPassword(SignUpData data) {
    if (data.password != null && data.password!.length >= 6) {
      return data.password!;
    }
    return _demoGooglePassword;
  }

  String? _nullablePhone(String? value) {
    final e164 = toE164Phone(value ?? '');
    if (e164.length < 11) return null;
    return e164;
  }

  Future<void> _upsertProfiles({
    required String userId,
    required UserRole role,
    required String email,
    String? phone,
  }) async {
    if (role == UserRole.worker) {
      final profile = WorkerProfileStore.instance.profile;
      await _client.from('profiles').upsert({
        'id': userId,
        'role': role.name,
        'first_name': profile?.firstName ?? '',
        'last_name': profile?.lastName ?? '',
        'email': profile?.email ?? email,
        'phone': _nullablePhone(profile?.phone ?? phone),
        'whatsapp': _nullablePhone(profile?.whatsapp),
        'age': profile?.age,
        'town': profile?.town ?? '',
        'country': profile?.country ?? 'Namibia',
        'avatar_url': profile?.profilePhotoPath,
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();
      await _client.from('worker_profiles').upsert({
        'id': userId,
        'bio': profile?.bio ?? '',
        'specializations':
            profile?.specializations.map((item) => item.name).toList() ?? [],
        'experience': profile?.experience?.name,
        'portfolio_urls': profile?.portfolioPhotoPaths ?? [],
        'id_document_url': profile?.idDocumentPath,
        'face_scan_url': profile?.faceScanPath,
      });
      await _client.from('certifications').delete().eq('worker_id', userId);
      final certifications = profile?.certifications ?? [];
      if (certifications.isNotEmpty) {
        await _client.from('certifications').insert(
              certifications
                  .map(
                    (item) => {
                      'worker_id': userId,
                      'title': item.title,
                      'issuer': item.issuer,
                      'document_url': item.documentPath,
                    },
                  )
                  .toList(),
            );
      }
      return;
    }

    final profile = CustomerProfileStore.instance.profile;
    await _client.from('profiles').upsert({
      'id': userId,
      'role': role.name,
      'first_name': profile?.firstName ?? '',
      'last_name': profile?.lastName ?? '',
      'email': profile?.email ?? email,
      'phone': _nullablePhone(profile?.phone ?? phone),
      'whatsapp': _nullablePhone(profile?.whatsapp),
      'age': profile?.age,
      'town': profile?.town ?? '',
      'country': profile?.country ?? 'Namibia',
      'avatar_url': profile?.profilePhotoPath,
      'contacted_worker_ids': profile?.contactedWorkerIds ?? [],
      'updated_at': DateTime.now().toIso8601String(),
    }).select().single();
  }

  Future<LocalAccount?> _loadAccount(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;

    final role = UserRole.values.byName(row['role'] as String? ?? 'customer');
    WorkerProfile? workerProfile;
    CustomerProfile? customerProfile;

    if (role == UserRole.worker) {
      final workerRow = await _client
          .from('worker_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      final certificationRows = await _client
          .from('certifications')
          .select()
          .eq('worker_id', userId);
      workerProfile = _workerFromRows(row, workerRow, certificationRows);
    } else {
      customerProfile = _customerFromRow(row);
    }

    return LocalAccount(
      id: userId,
      email: row['email'] as String? ?? '',
      phone: row['phone'] as String?,
      role: role,
      workerProfile: workerProfile,
      customerProfile: customerProfile,
    );
  }

  CustomerProfile _customerFromRow(Map<String, dynamic> row) {
    return CustomerProfile(
      firstName: row['first_name'] as String? ?? '',
      lastName: row['last_name'] as String? ?? '',
      email: row['email'] as String? ?? '',
      age: (row['age'] as num?)?.toInt() ?? 0,
      town: row['town'] as String? ?? '',
      country: row['country'] as String? ?? '',
      phone: row['phone'] as String?,
      whatsapp: row['whatsapp'] as String?,
      profilePhotoPath: row['avatar_url'] as String?,
      contactedWorkerIds:
          ((row['contacted_worker_ids'] as List<dynamic>?) ?? [])
              .map((id) => id as String)
              .toList(),
    );
  }

  WorkerProfile _workerFromRows(
    Map<String, dynamic> profile,
    Map<String, dynamic>? worker,
    List<dynamic> certifications,
  ) {
    return WorkerProfile(
      firstName: profile['first_name'] as String? ?? '',
      lastName: profile['last_name'] as String? ?? '',
      email: profile['email'] as String? ?? '',
      age: (profile['age'] as num?)?.toInt() ?? 0,
      town: profile['town'] as String? ?? '',
      country: profile['country'] as String? ?? '',
      phone: profile['phone'] as String?,
      whatsapp: profile['whatsapp'] as String?,
      profilePhotoPath: profile['avatar_url'] as String?,
      bio: worker?['bio'] as String? ?? '',
      specializations: ((worker?['specializations'] as List<dynamic>?) ?? [])
          .map((name) => TradeCategory.tryParse(name as String?))
          .whereType<TradeCategory>()
          .toList(),
      experience: worker?['experience'] == null
          ? null
          : WorkExperienceLevel.values.byName(worker!['experience'] as String),
      portfolioPhotoPaths:
          ((worker?['portfolio_urls'] as List<dynamic>?) ?? [])
              .map((path) => path as String)
              .toList(),
      idDocumentPath: worker?['id_document_url'] as String?,
      faceScanPath: worker?['face_scan_url'] as String?,
      certifications: certifications
          .map(
            (item) => WorkerCertification(
              title: item['title'] as String? ?? '',
              issuer: item['issuer'] as String? ?? '',
              documentPath: item['document_url'] as String? ?? '',
            ),
          )
          .toList(),
    );
  }
}
