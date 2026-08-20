import 'dart:typed_data';
import 'dart:ui' show loadFontFromList;

import 'package:archive/archive.dart';
import 'package:lottie/lottie.dart';

/// Decodes a `.lottie` zip (dotLottie v1 `animations/` or v2 `a/`)
/// and registers bundled fonts so live text layers render.
Future<LottieComposition?> decodeDotLottie(List<int> bytes) async {
  final composition = await LottieComposition.decodeZip(bytes);
  if (composition == null) return null;

  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive.files) {
    final lower = file.name.toLowerCase();
    if (!lower.endsWith('.ttf') && !lower.endsWith('.otf')) continue;

    final data = Uint8List.fromList(file.content);
    final families = <String>{
      ...composition.fonts.values.map((font) => font.family),
      ...composition.fonts.values.map((font) => font.name),
    };
    for (final family in families) {
      if (family.isEmpty) continue;
      await loadFontFromList(data, fontFamily: family);
    }
  }

  return composition;
}
