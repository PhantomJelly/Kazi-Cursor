import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/theme/kazi_text_styles.dart';
import 'package:kazi/supabase/media_storage.dart';

Future<ImageSource?> showPhotoSourceSheet(
  BuildContext context, {
  String? cameraLabel,
  String? galleryLabel,
}) {
  final camera = cameraLabel ?? t(context, 'photo.take');
  final gallery = galleryLabel ?? t(context, 'photo.gallery');
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: KaziColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KaziColors.grey15,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: KaziColors.primary,
                ),
                title: Text(camera, style: KaziTextStyles.button),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: KaziColors.primary,
                ),
                title: Text(gallery, style: KaziTextStyles.button),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class PhotoPicker {
  PhotoPicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndUpload(
    BuildContext context, {
    required String bucket,
    CameraDevice preferredCamera = CameraDevice.rear,
    double maxWidth = 1200,
    int imageQuality = 85,
    bool cameraOnly = false,
  }) async {
    // Web often has no camera; let the user pick a file instead.
    final source = cameraOnly && !kIsWeb
        ? ImageSource.camera
        : await showPhotoSourceSheet(context);
    if (source == null) return null;
    if (!context.mounted) return null;

    final file = await _pickOne(
      context,
      source: source,
      preferredCamera: preferredCamera,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
    if (file == null || !context.mounted) return null;
    return _upload(context, bucket: bucket, file: file);
  }

  static Future<List<String>> pickManyAndUpload(
    BuildContext context, {
    required String bucket,
    double maxWidth = 1200,
    int imageQuality = 85,
  }) async {
    final source = await showPhotoSourceSheet(context);
    if (source == null) return const [];
    if (!context.mounted) return const [];

    if (source == ImageSource.camera) {
      final file = await _pickOne(
        context,
        source: ImageSource.camera,
        maxWidth: maxWidth,
        imageQuality: imageQuality,
      );
      if (file == null || !context.mounted) return const [];
      final url = await _upload(context, bucket: bucket, file: file);
      return url == null ? const [] : [url];
    }

    try {
      final files = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        imageQuality: imageQuality,
      );
      if (files.isEmpty) return const [];
      final urls = <String>[];
      for (final file in files) {
        if (!context.mounted) return urls;
        final url = await _upload(context, bucket: bucket, file: file);
        if (url != null) urls.add(url);
      }
      return urls;
    } catch (error) {
      if (context.mounted) {
        _showError(context, t(context, 'photo.galleryFail', {'error': '$error'}));
      }
      return const [];
    }
  }

  static Future<XFile?> _pickOne(
    BuildContext context, {
    required ImageSource source,
    CameraDevice preferredCamera = CameraDevice.rear,
    required double maxWidth,
    required int imageQuality,
  }) async {
    try {
      return await _picker.pickImage(
        source: source,
        preferredCameraDevice: preferredCamera,
        maxWidth: maxWidth,
        imageQuality: imageQuality,
      );
    } catch (error) {
      _showError(
        context,
        source == ImageSource.camera
            ? t(context, 'photo.cameraUnavailable')
            : t(context, 'photo.galleryFail', {'error': '$error'}),
      );
      return null;
    }
  }

  static Future<String?> _upload(
    BuildContext context, {
    required String bucket,
    required XFile file,
  }) async {
    try {
      return await MediaStorage.upload(bucket: bucket, file: file);
    } catch (_) {
      _showError(
        context,
        t(context, 'photo.uploadFail'),
      );
      return null;
    }
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: KaziColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
