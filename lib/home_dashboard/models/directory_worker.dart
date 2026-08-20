import 'package:kazi/profile/models/worker_certification.dart';
import 'package:kazi/shared/constants/trade_categories.dart';
import 'package:kazi/shared/constants/work_experience_levels.dart';

/// A worker account as shown to customers (from Supabase).
class DirectoryWorker {
  const DirectoryWorker({
    required this.id,
    required this.name,
    required this.town,
    required this.country,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.bio,
    required this.trades,
    this.experience,
    this.photoUrl = '',
    this.portfolioPhotoUrls = const [],
    this.certifications = const [],
  });

  final String id;
  final String name;
  final String town;
  final String country;
  final String email;
  final String phone;
  final String whatsapp;
  final String bio;
  final List<TradeCategory> trades;
  final WorkExperienceLevel? experience;
  final String photoUrl;
  final List<String> portfolioPhotoUrls;
  final List<WorkerCertification> certifications;

  bool get isCertified =>
      certifications.any((item) => item.documentPath.isNotEmpty);

  String get heroTag => id;

  String get tradeLabel => trades.map((trade) => trade.label).join(', ');

  String get experienceLabel => experience?.label ?? '';

  DirectoryWorker withCertifications(List<WorkerCertification> certifications) {
    return DirectoryWorker(
      id: id,
      name: name,
      town: town,
      country: country,
      email: email,
      phone: phone,
      whatsapp: whatsapp,
      bio: bio,
      trades: trades,
      experience: experience,
      photoUrl: photoUrl,
      portfolioPhotoUrls: portfolioPhotoUrls,
      certifications: certifications,
    );
  }

  factory DirectoryWorker.fromRow(Map<String, dynamic> row) {
    final worker = _asMap(row['worker_profiles']);
    final firstName = row['first_name'] as String? ?? '';
    final lastName = row['last_name'] as String? ?? '';
    return DirectoryWorker(
      id: row['id'] as String? ?? '',
      name: '$firstName $lastName'.trim(),
      town: row['town'] as String? ?? '',
      country: row['country'] as String? ?? '',
      email: row['email'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      whatsapp: row['whatsapp'] as String? ?? '',
      photoUrl: row['avatar_url'] as String? ?? '',
      bio: worker?['bio'] as String? ?? '',
      trades: _trades(worker?['specializations']),
      experience: _experience(worker?['experience'] as String?),
      portfolioPhotoUrls: _strings(worker?['portfolio_urls']),
      certifications: _certifications(worker?['certifications']),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return null;
  }

  static List<String> _strings(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
  }

  static List<TradeCategory> _trades(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => TradeCategory.tryParse(item.toString()))
        .whereType<TradeCategory>()
        .toList();
  }

  static WorkExperienceLevel? _experience(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final level in WorkExperienceLevel.values) {
      if (level.name == name) return level;
    }
    return null;
  }

  static List<WorkerCertification> _certifications(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => WorkerCertification(
            title: item['title'] as String? ?? '',
            issuer: item['issuer'] as String? ?? '',
            documentPath: item['document_url'] as String? ??
                item['documentPath'] as String? ??
                '',
          ),
        )
        .toList();
  }
}
