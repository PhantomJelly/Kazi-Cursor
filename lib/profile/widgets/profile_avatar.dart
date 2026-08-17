import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';
import 'package:kazi/shared/utils/platform_image.dart' as platform_image;

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.path,
    this.radius = 36,
  });

  final String? path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (path != null) {
      image = platform_image.imageProviderFromPath(path!);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: KaziColors.grey8,
      backgroundImage: image,
      child: image == null
          ? Icon(Icons.person_outline,
              color: KaziColors.grey, size: radius * 0.9)
          : null,
    );
  }
}
