import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/profile/models/worker_certification.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/shared/widgets/kazi_text_field.dart';

class WorkerCertificationsScreen extends StatefulWidget {
  const WorkerCertificationsScreen({super.key});

  @override
  State<WorkerCertificationsScreen> createState() =>
      _WorkerCertificationsScreenState();
}

class _WorkerCertificationsScreenState extends State<WorkerCertificationsScreen> {
  final _titleController = TextEditingController();
  final _issuerController = TextEditingController();
  final _picker = ImagePicker();
  List<WorkerCertification> _certifications = [];
  String? _pendingDocumentPath;

  @override
  void initState() {
    super.initState();
    final profile = WorkerProfileStore.instance.profile;
    if (profile != null) {
      _certifications = List.of(profile.certifications);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file != null) setState(() => _pendingDocumentPath = file.path);
  }

  void _addCertification() {
    final title = _titleController.text.trim();
    final issuer = _issuerController.text.trim();
    if (title.isEmpty || issuer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter certification title and issuer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_pendingDocumentPath == null || _pendingDocumentPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach your certificate document'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _certifications = [
        ..._certifications,
        WorkerCertification(
          title: title,
          issuer: issuer,
          documentPath: _pendingDocumentPath!,
        ),
      ];
      _titleController.clear();
      _issuerController.clear();
      _pendingDocumentPath = null;
    });
  }

  void _removeCertification(int index) {
    setState(() => _certifications.removeAt(index));
  }

  void _persist() {
    final title = _titleController.text.trim();
    final issuer = _issuerController.text.trim();
    var certifications = List<WorkerCertification>.of(_certifications);
    if (title.isNotEmpty &&
        issuer.isNotEmpty &&
        _pendingDocumentPath != null &&
        _pendingDocumentPath!.isNotEmpty) {
      certifications = [
        ...certifications,
        WorkerCertification(
          title: title,
          issuer: issuer,
          documentPath: _pendingDocumentPath!,
        ),
      ];
    }
    WorkerProfileStore.instance.updateCertifications(certifications);
  }

  void _save() {
    _persist();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: KaziColors.white,
        systemNavigationBarColor: KaziColors.white,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _persist();
          Navigator.of(context).pop();
        },
        child: Scaffold(
        backgroundColor: KaziColors.white,
        appBar: AppBar(
          backgroundColor: KaziColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Certifications', style: KaziTextStyles.button),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add your qualifications',
                        style: KaziTextStyles.heading,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'BONUS section — earn a Certified badge on your profile. A certificate document is required for each entry.',
                        style: KaziTextStyles.subtitle.copyWith(
                          color: KaziColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_certifications.isNotEmpty) ...[
                        Text('Your certifications', style: KaziTextStyles.label),
                        const SizedBox(height: 12),
                        ..._certifications.asMap().entries.map((entry) {
                          final cert = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: KaziColors.grey15,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  color: KaziColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(cert.title,
                                          style: KaziTextStyles.button),
                                      Text(
                                        cert.issuer,
                                        style: KaziTextStyles.subtitle
                                            .copyWith(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: KaziColors.grey, size: 20),
                                  onPressed: () =>
                                      _removeCertification(entry.key),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                      Text('Add certification', style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      KaziTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'e.g. Plumbing Level 2',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      KaziTextField(
                        controller: _issuerController,
                        label: 'Issuer',
                        hint: 'e.g. Namibia Training Authority',
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickDocument,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: KaziColors.grey8,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: KaziColors.grey15,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file_outlined,
                                  color: KaziColors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _pendingDocumentPath != null
                                      ? 'Certificate attached'
                                      : 'Attach certificate (required)',
                                  style: KaziTextStyles.subtitle.copyWith(
                                    fontSize: 14,
                                    color: KaziColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      KaziButton(
                        label: 'Add to list',
                        variant: KaziButtonVariant.outline,
                        onPressed: _addCertification,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: KaziButton(label: 'Save', onPressed: _save),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
