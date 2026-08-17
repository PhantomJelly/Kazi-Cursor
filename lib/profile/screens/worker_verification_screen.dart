import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/profile/services/worker_profile_store.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;
import 'package:kazi/shared/widgets/kazi_button.dart';

class WorkerVerificationScreen extends StatefulWidget {
  const WorkerVerificationScreen({super.key});

  @override
  State<WorkerVerificationScreen> createState() =>
      _WorkerVerificationScreenState();
}

class _WorkerVerificationScreenState extends State<WorkerVerificationScreen> {
  final _picker = ImagePicker();
  String? _idDocumentPath;
  String? _faceScanPath;

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
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 90,
    );
    if (file != null) setState(() => _idDocumentPath = file.path);
  }

  Future<void> _scanFace() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file != null) setState(() => _faceScanPath = file.path);
  }

  void _persist() {
    WorkerProfileStore.instance.updateVerification(
      idDocumentPath: _idDocumentPath,
      faceScanPath: _faceScanPath,
    );
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
          title: Text('Verification', style: KaziTextStyles.button),
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
                      Text('Verify your identity', style: KaziTextStyles.heading),
                      const SizedBox(height: 12),
                      Text(
                        'Upload a clear photo of your ID or passport, then scan your face so customers know you are verified.',
                        style: KaziTextStyles.subtitle.copyWith(
                          color: KaziColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('ID or passport', style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      _UploadTile(
                        label: _idDocumentPath != null
                            ? 'ID document uploaded'
                            : 'Upload ID or passport photo',
                        icon: Icons.badge_outlined,
                        imagePath: _idDocumentPath,
                        onTap: _pickIdDocument,
                      ),
                      const SizedBox(height: 24),
                      Text('Face scan', style: KaziTextStyles.label),
                      const SizedBox(height: 12),
                      _UploadTile(
                        label: _faceScanPath != null
                            ? 'Face scan complete'
                            : 'Scan your face with camera',
                        icon: Icons.face_retouching_natural_outlined,
                        imagePath: _faceScanPath,
                        onTap: _scanFace,
                        isCircular: true,
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

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.imagePath,
    this.isCircular = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? imagePath;
  final bool isCircular;

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
            if (hasImage)
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
