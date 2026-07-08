import 'package:flutter/material.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../domain/entities/wallpaper.dart';

class WallpaperPreview extends StatelessWidget {
  const WallpaperPreview({
    required this.wallpaper,
    this.height,
    this.borderRadius = AppRadii.lg,
    this.useThumbnail = false,
    this.cacheWidth,
    super.key,
  });

  final Wallpaper wallpaper;
  final double? height;
  final double borderRadius;
  final bool useThumbnail;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final assetPath = useThumbnail
        ? wallpaper.thumbnailAssetPath ?? wallpaper.localAssetPath
        : wallpaper.localAssetPath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          final color = Color(int.parse('FF${wallpaper.colorHex}', radix: 16));
          return Container(
            height: height,
            color: color.withValues(alpha: 0.78),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              wallpaper.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        },
      ),
    );
  }
}
