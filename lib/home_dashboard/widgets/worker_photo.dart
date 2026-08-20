import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;

class WorkerPhoto extends StatelessWidget {
  const WorkerPhoto({
    super.key,
    required this.photoUrl,
    this.radius = 24,
    this.heroTag,
  });

  final String photoUrl;
  final double radius;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl.trim();
    final image = url.isEmpty ? null : platform_image.imageProviderFromPath(url);
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: KaziColors.grey8,
      backgroundImage: image,
      onBackgroundImageError: image == null ? null : (_, _) {},
      child: image == null
          ? Icon(
              Icons.person_outline,
              color: KaziColors.grey,
              size: radius * 0.9,
            )
          : null,
    );

    if (heroTag == null) return avatar;

    return Hero(
      tag: heroTag!,
      child: avatar,
    );
  }
}
