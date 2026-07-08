import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF1E73E8);
  static const primarySoft = Color(0xFFE2F1FF);
  static const sky = Color(0xFFEAF6FF);
  static const skyLight = Color(0xFFF8FCFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceGlass = Color(0xD9FFFFFF);
  static const ink = Color(0xFF102F5F);
  static const text = Color(0xFF243A5E);
  static const muted = Color(0xFF6D7F9C);
  static const border = Color(0xBFFFFFFF);
  static const warning = Color(0xFFF0A72F);
  static const error = Color(0xFFB42318);
}

class AppSpacing {
  const AppSpacing._();

  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const page = EdgeInsets.fromLTRB(16, 12, 16, 112);
}

class AppRadii {
  const AppRadii._();

  static const sm = 14.0;
  static const md = 18.0;
  static const lg = 24.0;
  static const xl = 28.0;
  static const xxl = 34.0;
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get dock => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppGradients {
  const AppGradients._();

  static const page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.sky, AppColors.skyLight, Color(0xFFEFF8FF)],
  );

  static LinearGradient glass([Color? base]) {
    final color = base ?? AppColors.surface;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 0.88),
        AppColors.sky.withValues(alpha: 0.58),
      ],
    );
  }
}

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(ColorScheme colorScheme) {
    const base = TextStyle(
      fontFamily: 'Roboto',
      color: AppColors.text,
      letterSpacing: 0,
    );

    return TextTheme(
      displayLarge: base.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
      displaySmall: base.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      headlineMedium: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
      headlineSmall: base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleLarge: base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
      titleMedium: base.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      titleSmall: base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      bodyLarge: base.copyWith(fontSize: 16, height: 1.45),
      bodyMedium: base.copyWith(fontSize: 14, height: 1.38),
      bodySmall: base.copyWith(
        fontSize: 12,
        height: 1.32,
        color: AppColors.muted,
      ),
      labelLarge: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      labelMedium: base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
      ),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
      ),
    );
  }

  static TextStyle arabic(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall!.copyWith(
      fontSize: 34,
      height: 1.6,
      color: AppColors.ink,
      fontWeight: FontWeight.w700,
    );
  }
}
