import 'package:flutter/material.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

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
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: KaziColors.grey8,
      backgroundImage: NetworkImage(photoUrl),
      onBackgroundImageError: (_, _) {},
    );

    if (heroTag == null) return avatar;

    return Hero(
      tag: heroTag!,
      child: avatar,
    );
  }
}
