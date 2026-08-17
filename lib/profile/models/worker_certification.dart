class WorkerCertification {
  const WorkerCertification({
    required this.title,
    required this.issuer,
    required this.documentPath,
  });

  final String title;
  final String issuer;
  final String documentPath;

  Map<String, dynamic> toJson() => {
        'title': title,
        'issuer': issuer,
        'documentPath': documentPath,
      };

  factory WorkerCertification.fromJson(Map<String, dynamic> json) {
    return WorkerCertification(
      title: json['title'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      documentPath: json['documentPath'] as String? ?? '',
    );
  }
}
