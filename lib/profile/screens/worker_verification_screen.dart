import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/photo_picker.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;
import 'package:kazi/shared/widgets/kazi_button.dart';
import 'package:kazi/supabase/media_storage.dart';

class WorkerVerificationScreen extends StatefulWidget {
  const WorkerVerificationScreen({super.key});

  @override
  State<WorkerVerificationScreen> createState() =>
      _WorkerVerificationScreenState();
}

class _WorkerVerificationScreenState extends State<WorkerVerificationScreen> {
  String? _idDocumentPath;
  String? _faceScanPath;
  bool _isUploadingId = false;
  bool _isUploadingFace = false;

  @override
  void initState() {
    super.initState();
    final profile = WorkerProfileStore.instance.profile;
    if (profile != null) {
      _idDocumentPath = profile.idDocumentPath;
      _faceScanPath = profile.faceScanPath;
    }
  }

  Future<void> _pickIdDocument() async {
    if (_isUploadingId) return;
    setState(() => _isUploadingId = true);
    final url = await PhotoPicker.pickAndUpload(
      context,
      bucket: MediaStorage.verification,
      maxWidth: 1600,
      imageQuality: 90,
    );
    if (!mounted) return;
    setState(() {
      _isUploadingId = false;
      if (url != null) _idDocumentPath = url;
    });
  }

  Future<void> _scanFace() async {
    if (_isUploadingFace) return;
    setState(() => _isUploadingFace = true);
    final url = await PhotoPicker.pickAndUpload(
      context,
      bucket: MediaStorage.verification,
      preferredCamera: CameraDevice.front,
      cameraOnly: true,
    );
    if (!mounted) return;
    setState(() {
      _isUploadingFace = false;
      if (url != null) _faceScanPath = url;
    });
  }

  Future<void> _persist() async {
    await WorkerProfileStore.instance.updateVerification(
      idDocumentPath: _idDocumentPath,
      faceScanPath: _faceScanPath,
    );
  }

  Future<void> _save() async {
    await _persist();
    if (mounted) Navigator.of(context).pop();
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
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _persist();
          if (context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
        backgroundColor: KaziColors.white,
        appBar: AppBar(
          backgroundColor: KaziColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: KaziColors.primary, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(t(context, 'profile.verification'), style: KaziTextStyles.button),
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
                      Text(t(context, 'profile.verifyTitle'), style: KaziTextStyles.heading),
                      const SizedBox(height: 12),
                      Text(
                        t(context, 'profile.verifyBody'),
                        style: KaziTextStyles.subtitle.copyWith(
                          color: KaziColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(t(context, 'profile.idPassport'), style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      _UploadTile(
                        label: _isUploadingId
                            ? t(context, 'profile.uploading')
                            : _idDocumentPath != null
                                ? t(context, 'profile.idUploaded')
                                : t(context, 'profile.takeOrChoose'),
                        icon: Icons.badge_outlined,
                        imagePath: _idDocumentPath,
                        isUploading: _isUploadingId,
                        onTap: _pickIdDocument,
                      ),
                      const SizedBox(height: 24),
                      Text(t(context, 'profile.faceScan'), style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      _UploadTile(
                        label: _isUploadingFace
                            ? t(context, 'profile.uploading')
                            : _faceScanPath != null
                                ? t(context, 'profile.faceDone')
                                : t(context, 'profile.scanFace'),
                        icon: Icons.face_retouching_natural_outlined,
                        imagePath: _faceScanPath,
                        isUploading: _isUploadingFace,
                        onTap: _scanFace,
                        isCircular: true,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: KaziButton(label: t(context, 'common.save'), onPressed: _save),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.imagePath,
    this.isCircular = false,
    this.isUploading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? imagePath;
  final bool isCircular;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KaziColors.grey8,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KaziColors.grey15, width: 1.5),
        ),
        child: Row(
          children: [
            if (isUploading)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: KaziColors.primary,
                ),
              )
            else if (hasImage)
              ClipRRect(
                borderRadius:
                    isCircular ? BorderRadius.circular(32) : BorderRadius.circular(8),
                child: Image(
                  image: platform_image.imageProviderFromPath(imagePath!),
                  width: isCircular ? 64 : 72,
                  height: isCircular ? 64 : 48,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(icon, color: KaziColors.grey, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: KaziTextStyles.subtitle.copyWith(
                  fontSize: 14,
                  color: KaziColors.textPrimary,
                ),
              ),
            ),
            Icon(
              hasImage ? Icons.check_circle : Icons.add_a_photo_outlined,
              color: hasImage ? KaziColors.primary : KaziColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
