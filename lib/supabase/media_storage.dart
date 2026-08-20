import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaStorage {
  MediaStorage._();

  static const avatars = 'avatars';
  static const portfolio = 'portfolio';
  static const verification = 'verification';
  static const certificates = 'certificates';

  static bool isRemoteUrl(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  static Future<String> upload({
    required String bucket,
    required XFile file,
  }) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in before uploading a photo.');
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('The selected photo could not be read.');
    }

    final ext = _extension(file);
    final objectPath =
        '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await client.storage.from(bucket).uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/jpeg',
            upsert: true,
          ),
        );

    return client.storage.from(bucket).getPublicUrl(objectPath);
  }

  static String _extension(XFile file) {
    final name = file.name.toLowerCase();
    final fromName = name.contains('.') ? name.split('.').last : '';
    if (fromName == 'png' ||
        fromName == 'jpg' ||
        fromName == 'jpeg' ||
        fromName == 'webp' ||
        fromName == 'heic') {
      return fromName == 'jpeg' ? 'jpg' : fromName;
    }

    final mime = (file.mimeType ?? '').toLowerCase();
    if (mime.contains('png')) return 'png';
    if (mime.contains('webp')) return 'webp';
    if (mime.contains('heic')) return 'heic';
    return 'jpg';
  }
}
