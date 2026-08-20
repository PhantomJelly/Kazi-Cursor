import 'package:flutter/foundation.dart';
import 'package:kazi/home_dashboard/models/directory_worker.dart';
import 'package:kazi/profile/models/worker_certification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerDirectoryStore extends ChangeNotifier {
  WorkerDirectoryStore._();

  static final WorkerDirectoryStore instance = WorkerDirectoryStore._();

  static const _select =
      'id, first_name, last_name, email, phone, whatsapp, town, country, avatar_url, worker_profiles(bio, specializations, experience, portfolio_urls)';

  List<DirectoryWorker> _workers = [];
  var loading = false;
  var loadFailed = false;

  List<DirectoryWorker> get workers => List.unmodifiable(_workers);

  SupabaseClient get _client => Supabase.instance.client;

  DirectoryWorker? byId(String id) {
    for (final worker in _workers) {
      if (worker.id == id) return worker;
    }
    return null;
  }

  Future<DirectoryWorker?> resolve(String id) async {
    final cached = byId(id);
    if (cached != null) return cached;
    return fetchById(id);
  }

  Future<void> refresh() async {
    loading = true;
    loadFailed = false;
    notifyListeners();
    try {
      if (_client.auth.currentUser == null) {
        _workers = [];
        return;
      }
      final rows = await _client
          .from('profiles')
          .select(_select)
          .eq('role', 'worker')
          .order('first_name');
      final parsed = (rows as List<dynamic>)
          .map(
            (row) => DirectoryWorker.fromRow(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .where((worker) => worker.name.isNotEmpty)
          .toList();
      _workers = await _withCertifications(parsed);
      loadFailed = false;
    } catch (_) {
      loadFailed = true;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<DirectoryWorker?> fetchById(String id) async {
    if (id.isEmpty) return null;
    try {
      final row = await _client
          .from('profiles')
          .select(_select)
          .eq('id', id)
          .eq('role', 'worker')
          .maybeSingle();
      if (row == null) return null;
      var worker = DirectoryWorker.fromRow(Map<String, dynamic>.from(row));
      if (worker.name.isEmpty) return null;
      worker = (await _withCertifications([worker])).first;
      final index = _workers.indexWhere((item) => item.id == worker.id);
      if (index >= 0) {
        _workers[index] = worker;
      } else {
        _workers.add(worker);
      }
      notifyListeners();
      return worker;
    } catch (_) {
      return null;
    }
  }

  Future<List<DirectoryWorker>> _withCertifications(
    List<DirectoryWorker> workers,
  ) async {
    if (workers.isEmpty) return workers;
    try {
      final rows = await _client
          .from('certifications')
          .select('worker_id, title, issuer, document_url')
          .inFilter('worker_id', workers.map((worker) => worker.id).toList());
      final byWorker = <String, List<WorkerCertification>>{};
      for (final row in rows as List<dynamic>) {
        final map = Map<String, dynamic>.from(row as Map);
        final workerId = map['worker_id'] as String? ?? '';
        byWorker.putIfAbsent(workerId, () => []).add(
              WorkerCertification(
                title: map['title'] as String? ?? '',
                issuer: map['issuer'] as String? ?? '',
                documentPath: map['document_url'] as String? ?? '',
              ),
            );
      }
      return workers
          .map(
            (worker) =>
                worker.withCertifications(byWorker[worker.id] ?? const []),
          )
          .toList();
    } catch (_) {
      return workers;
    }
  }
}
