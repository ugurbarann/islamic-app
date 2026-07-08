import 'package:flutter/material.dart';

import '../../app/theme/app_design_system.dart';
import 'app_illustrations.dart';

enum AppFeatureIconKind {
  quran,
  qibla,
  dua,
  tasbih,
  mosque,
  kaaba,
  wallpaper,
  hadith,
  calendar,
  knowledge,
  esma,
}

class AppFeatureIcon extends StatelessWidget {
  const AppFeatureIcon({
    required this.kind,
    this.size = 48,
    this.iconSize,
    this.color,
    super.key,
  });

  final AppFeatureIconKind kind;
  final double size;
  final double? iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(kind);
    final primary = color ?? colors.primary;
    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.96),
              (color ?? colors.soft).withValues(
                alpha: color == null ? 0.78 : 0.10,
              ),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        ),
        child: Center(
          child: AppIllustration(
            kind: colors.illustration,
            size: iconSize ?? size * 0.62,
            primary: primary,
            accent: colors.accent,
          ),
        ),
      ),
    );
  }

  _FeatureIconColors _colorsFor(AppFeatureIconKind kind) {
    return switch (kind) {
      AppFeatureIconKind.quran => const _FeatureIconColors(
        illustration: AppIllustrationKind.quran,
        primary: AppColors.primary,
        accent: AppColors.warning,
        soft: Color(0xFFE3F3FF),
      ),
      AppFeatureIconKind.qibla => const _FeatureIconColors(
        illustration: AppIllustrationKind.compass,
        primary: Color(0xFF1C6ECF),
        accent: Color(0xFFF2B544),
        soft: Color(0xFFEAF5FF),
      ),
      AppFeatureIconKind.dua => const _FeatureIconColors(
        illustration: AppIllustrationKind.crescent,
        primary: Color(0xFF2873D9),
        accent: Color(0xFFF2B544),
        soft: Color(0xFFEFF6FF),
      ),
      AppFeatureIconKind.tasbih => const _FeatureIconColors(
        illustration: AppIllustrationKind.tasbih,
        primary: Color(0xFF1769C2),
        accent: Color(0xFFF3B33E),
        soft: Color(0xFFEAF5FF),
      ),
      AppFeatureIconKind.mosque => const _FeatureIconColors(
        illustration: AppIllustrationKind.mosque,
        primary: Color(0xFF1B6CCB),
        accent: Color(0xFFE8A92F),
        soft: Color(0xFFE8F6FF),
      ),
      AppFeatureIconKind.kaaba => const _FeatureIconColors(
        illustration: AppIllustrationKind.kaaba,
        primary: Color(0xFF163A64),
        accent: Color(0xFFE8A92F),
        soft: Color(0xFFE8F4FF),
      ),
      AppFeatureIconKind.wallpaper => const _FeatureIconColors(
        illustration: AppIllustrationKind.wallpaper,
        primary: Color(0xFF2D79D9),
        accent: Color(0xFFF0B13B),
        soft: Color(0xFFE7F4FF),
      ),
      AppFeatureIconKind.hadith => const _FeatureIconColors(
        illustration: AppIllustrationKind.knowledge,
        primary: Color(0xFF226ED6),
        accent: Color(0xFFE6A72F),
        soft: Color(0xFFF1F5FF),
      ),
      AppFeatureIconKind.calendar => const _FeatureIconColors(
        illustration: AppIllustrationKind.friday,
        primary: Color(0xFF246FD2),
        accent: Color(0xFFE9AA35),
        soft: Color(0xFFF0F7FF),
      ),
      AppFeatureIconKind.knowledge => const _FeatureIconColors(
        illustration: AppIllustrationKind.knowledge,
        primary: AppColors.primary,
        accent: AppColors.warning,
        soft: Color(0xFFE3F3FF),
      ),
      AppFeatureIconKind.esma => const _FeatureIconColors(
        illustration: AppIllustrationKind.esma,
        primary: Color(0xFF226ED6),
        accent: Color(0xFFE6A72F),
        soft: Color(0xFFF1F5FF),
      ),
    };
  }
}

class _FeatureIconColors {
  const _FeatureIconColors({
    required this.illustration,
    required this.primary,
    required this.accent,
    required this.soft,
  });

  final AppIllustrationKind illustration;
  final Color primary;
  final Color accent;
  final Color soft;
}
