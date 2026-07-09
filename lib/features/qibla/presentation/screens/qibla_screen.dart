import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/qibla_direction.dart';
import '../../domain/entities/qibla_status.dart';
import '../controllers/qibla_controller.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directionAsync = ref.watch(qiblaDirectionProvider);

    return PremiumScaffold(
      title: 'Kıble Yönü',
      body: directionAsync.when(
        data: (direction) => _QiblaLiveContent(direction: direction),
        loading: () => const LoadingState(title: 'Kıble yönü hesaplanıyor'),
        error: (error, stackTrace) => ErrorState(
          title: 'Kıble yönü hesaplanıyor',
          message: error.toString(),
        ),
      ),
    );
  }
}

class _QiblaLiveContent extends ConsumerWidget {
  const _QiblaLiveContent({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compassAsync = ref.watch(compassReadingProvider);
    final compass = compassAsync.asData?.value;
    final displayDirection = compass?.status == QiblaStatus.ready
        ? direction.withCompassHeading(compass?.heading)
        : direction;

    final status = compass?.status == QiblaStatus.compassUnavailable
        ? QiblaStatus.compassUnavailable
        : displayDirection.status;

    if (status != QiblaStatus.ready) {
      return _QiblaFallback(status: status);
    }

    return PremiumScrollView(
      children: [
        GlassPanel(
          borderRadius: 32,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            children: [
              Text(
                'Kıble Yönü',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yaklaşık yönlendirme için pusulayı düz tutun.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _QiblaGuidance(direction: displayDirection),
              const SizedBox(height: 14),
              RepaintBoundary(
                child: _CompassVisual(direction: displayDirection),
              ),
              const SizedBox(height: 14),
              _QiblaStatusBanner(direction: displayDirection),
              const SizedBox(height: 12),
              _QiblaMetricGrid(direction: displayDirection),
              const SizedBox(height: 12),
              _QiblaInfoStrip(direction: displayDirection),
            ],
          ),
        ),
      ],
    );
  }
}

class _QiblaGuidance extends StatelessWidget {
  const _QiblaGuidance({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    final guidance = _guidanceFor(direction.difference);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(guidance.icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                guidance.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _QiblaGuidanceData _guidanceFor(double? difference) {
    if (difference == null) {
      return const _QiblaGuidanceData(
        'Telefonu yavaşça çevirin',
        Icons.screen_rotation_alt_outlined,
      );
    }
    if (difference.abs() <= 8) {
      return const _QiblaGuidanceData(
        'Kıble yönündesiniz',
        Icons.check_circle_outline_rounded,
      );
    }
    if (difference > 0) {
      return const _QiblaGuidanceData('Sağa dönün', Icons.turn_right_rounded);
    }
    return const _QiblaGuidanceData('Sola dönün', Icons.turn_left_rounded);
  }
}

class _QiblaGuidanceData {
  const _QiblaGuidanceData(this.text, this.icon);

  final String text;
  final IconData icon;
}

class _CompassVisual extends StatelessWidget {
  const _CompassVisual({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        isComplex: true,
        painter: _CompassPainter(
          qiblaDifference: direction.difference ?? 0,
          heading: direction.heading,
          qiblaAngle: direction.qiblaAngle,
          textStyle: Theme.of(context).textTheme.labelLarge!,
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter({
    required this.qiblaDifference,
    required this.heading,
    required this.qiblaAngle,
    required this.textStyle,
  });

  final double qiblaDifference;
  final double? heading;
  final double? qiblaAngle;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final outerRadius = radius - 8;
    final innerRadius = outerRadius - 18;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFE8F5FF)],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primary.withValues(alpha: 0.18);

    final tickPaint = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.muted.withValues(alpha: 0.48);

    canvas.drawCircle(center, outerRadius, fillPaint);
    canvas.drawCircle(center, outerRadius, ringPaint);
    canvas.drawCircle(center, innerRadius, ringPaint);

    for (var i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * math.pi / 180;
      final isMajor = i % 5 == 0;
      final startRadius = outerRadius - (isMajor ? 14 : 8);
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * startRadius;
      final end =
          center + Offset(math.cos(angle), math.sin(angle)) * outerRadius;
      tickPaint
        ..strokeWidth = isMajor ? 2.2 : 1.1
        ..color = isMajor
            ? AppColors.primary.withValues(alpha: 0.32)
            : AppColors.muted.withValues(alpha: 0.34);
      canvas.drawLine(start, end, tickPaint);
    }

    _drawDirectionLabel(canvas, center, outerRadius * 0.72, 'K', 0);
    _drawDirectionLabel(canvas, center, outerRadius * 0.72, 'D', 90);
    _drawDirectionLabel(canvas, center, outerRadius * 0.72, 'G', 180);
    _drawDirectionLabel(canvas, center, outerRadius * 0.72, 'B', 270);

    final qiblaAngleRadians = (qiblaDifference - 90) * math.pi / 180;
    final qiblaVector = Offset(
      math.cos(qiblaAngleRadians),
      math.sin(qiblaAngleRadians),
    );
    final arrowEnd = center + qiblaVector * (outerRadius * 0.62);

    final guidePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.10),
          AppColors.primary.withValues(alpha: 0.70),
        ],
      ).createShader(Rect.fromPoints(center, arrowEnd))
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, arrowEnd, guidePaint);

    final headPaint = Paint()..color = AppColors.primary;
    final leftAngle = qiblaAngleRadians + math.pi * 0.78;
    final rightAngle = qiblaAngleRadians - math.pi * 0.78;
    final arrowHead = Path()
      ..moveTo(arrowEnd.dx, arrowEnd.dy)
      ..lineTo(
        arrowEnd.dx + math.cos(leftAngle) * 18,
        arrowEnd.dy + math.sin(leftAngle) * 18,
      )
      ..lineTo(
        arrowEnd.dx + math.cos(rightAngle) * 18,
        arrowEnd.dy + math.sin(rightAngle) * 18,
      )
      ..close();
    canvas.drawPath(arrowHead, headPaint);

    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 34, centerPaint);
    canvas.drawCircle(
      center,
      34,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFF28A85A).withValues(alpha: 0.78),
    );

    _drawKaaba(canvas, center);
  }

  void _drawKaaba(Canvas canvas, Offset center) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 4), width: 42, height: 36),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF151820), Color(0xFF050609)],
        ).createShader(body.outerRect),
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 21, center.dy - 3, 42, 6),
      Paint()..color = const Color(0xFFD9A944),
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 21, center.dy - 14)
        ..lineTo(center.dx, center.dy - 25)
        ..lineTo(center.dx + 21, center.dy - 14)
        ..lineTo(center.dx + 21, center.dy + 22)
        ..lineTo(center.dx - 21, center.dy + 22)
        ..close(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: .16),
    );
  }

  void _drawDirectionLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String label,
    double degrees,
  ) {
    final angle = (degrees - 90) * math.pi / 180;
    final offset = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      offset - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.qiblaDifference != qiblaDifference ||
        oldDelegate.heading != heading ||
        oldDelegate.qiblaAngle != qiblaAngle;
  }
}

class _QiblaStatusBanner extends StatelessWidget {
  const _QiblaStatusBanner({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    final difference = direction.difference?.abs();
    final isClose = difference != null && difference <= 8;
    final title = isClose
        ? 'Neredeyse doğru yöne bakıyorsunuz'
        : 'Telefonu yavaşça çevirin';
    final subtitle = difference == null
        ? 'Pusula değeri bekleniyor.'
        : 'Kıbleye ${difference.round()}° kaldı.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF4).withValues(alpha: .9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBEE8CF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF25A95A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaMetricGrid extends StatelessWidget {
  const _QiblaMetricGrid({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QiblaMetricCard(
            icon: Icons.location_on_rounded,
            label: 'Kıble Açısı',
            value: _degree(direction.qiblaAngle),
            color: const Color(0xFF25A95A),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QiblaMetricCard(
            icon: Icons.explore_rounded,
            label: 'Mevcut Yön',
            value: _degree(direction.heading),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QiblaMetricCard(
            icon: Icons.my_location_rounded,
            label: 'Fark',
            value: _degree(direction.difference?.abs()),
            color: const Color(0xFF25A95A),
          ),
        ),
      ],
    );
  }

  String _degree(double? value) {
    if (value == null) {
      return '--°';
    }
    return '${value.round()}°';
  }
}

class _QiblaMetricCard extends StatelessWidget {
  const _QiblaMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaInfoStrip extends StatelessWidget {
  const _QiblaInfoStrip({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    const location = 'Cihaz konumu kullanılıyor';
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final updatedAt = '$hour:$minute';

    return Row(
      children: [
        Expanded(
          child: _QiblaInfoTile(
            icon: Icons.place_rounded,
            title: 'Konum',
            value: location,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QiblaInfoTile(
            icon: Icons.schedule_rounded,
            title: 'Son Güncelleme',
            value: updatedAt,
          ),
        ),
      ],
    );
  }
}

class _QiblaInfoTile extends StatelessWidget {
  const _QiblaInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .68),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaFallback extends ConsumerWidget {
  const _QiblaFallback({required this.status});

  final QiblaStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompass = status == QiblaStatus.compassUnavailable;
    final isPermission = status == QiblaStatus.locationPermissionRequired;
    final isService = status == QiblaStatus.locationServiceDisabled;
    final icon = isCompass
        ? Icons.explore_off_outlined
        : isPermission
        ? Icons.location_searching_rounded
        : Icons.location_off_outlined;
    final helperText = isCompass
        ? 'Telefonunuzu sekiz çizerek hareket ettirin. Devam etmezse cihaz pusulası kullanılamıyor olabilir.'
        : isService
        ? 'Kıbleyi hesaplamak için iPhone konum servisleri açık olmalı.'
        : 'İzin ver düğmesine basınca iOS konum iznini isteyeceğiz. Daha önce reddettiyseniz Ayarlar ekranından açabilirsiniz.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassPanel(
          borderRadius: 32,
          color: Colors.white.withValues(alpha: .92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 58, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                qiblaStatusMessage(status),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                helperText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              if (isPermission)
                FilledButton.icon(
                  onPressed: () => _requestLocationPermission(ref),
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Konuma İzin Ver'),
                )
              else if (isService)
                FilledButton.icon(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    ref.invalidate(qiblaDirectionProvider);
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Konum Servisini Aç'),
                )
              else
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(qiblaDirectionProvider);
                    ref.invalidate(compassReadingProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tekrar Dene'),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await openAppSettings();
                  ref.invalidate(qiblaDirectionProvider);
                  ref.invalidate(compassReadingProvider);
                },
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Ayarları Aç'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission(WidgetRef ref) async {
    final permission = await Permission.locationWhenInUse.request();
    if (permission.isPermanentlyDenied || permission.isRestricted) {
      await openAppSettings();
    }
    ref.invalidate(qiblaDirectionProvider);
    ref.invalidate(compassReadingProvider);
  }
}
