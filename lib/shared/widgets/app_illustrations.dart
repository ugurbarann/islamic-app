import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_design_system.dart';

enum AppIllustrationKind {
  mosque,
  kaaba,
  quran,
  tasbih,
  crescent,
  compass,
  wallpaper,
  knowledge,
  friday,
  esma,
}

class AppIllustration extends StatelessWidget {
  const AppIllustration({
    required this.kind,
    this.size = 42,
    this.primary = AppColors.primary,
    this.accent = AppColors.warning,
    super.key,
  });

  final AppIllustrationKind kind;
  final double size;
  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _AppIllustrationPainter(
          kind: kind,
          primary: primary,
          accent: accent,
        ),
      ),
    );
  }
}

class _AppIllustrationPainter extends CustomPainter {
  const _AppIllustrationPainter({
    required this.kind,
    required this.primary,
    required this.accent,
  });

  final AppIllustrationKind kind;
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case AppIllustrationKind.mosque:
        _drawMosque(canvas, size);
      case AppIllustrationKind.kaaba:
        _drawKaaba(canvas, size);
      case AppIllustrationKind.quran:
        _drawQuran(canvas, size);
      case AppIllustrationKind.tasbih:
        _drawTasbih(canvas, size);
      case AppIllustrationKind.crescent:
        _drawCrescent(canvas, size);
      case AppIllustrationKind.compass:
        _drawCompass(canvas, size);
      case AppIllustrationKind.wallpaper:
        _drawWallpaper(canvas, size);
      case AppIllustrationKind.knowledge:
        _drawKnowledge(canvas, size);
      case AppIllustrationKind.friday:
        _drawFriday(canvas, size);
      case AppIllustrationKind.esma:
        _drawEsma(canvas, size);
    }
  }

  void _drawMosque(Canvas canvas, Size size) {
    final stroke = _stroke(size);
    final fill = Paint()..color = primary.withValues(alpha: 0.13);
    final base = Rect.fromLTWH(
      size.width * .18,
      size.height * .56,
      size.width * .64,
      size.height * .22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, Radius.circular(size.width * .06)),
      fill,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .30,
        size.height * .28,
        size.width * .40,
        size.height * .46,
      ),
      math.pi,
      math.pi,
      false,
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * .20, size.height * .78),
      Offset(size.width * .84, size.height * .78),
      stroke,
    );
    for (final x in [.18, .82]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * .25),
        Offset(size.width * x, size.height * .78),
        stroke,
      );
      canvas.drawCircle(
        Offset(size.width * x, size.height * .22),
        size.width * .045,
        Paint()..color = accent,
      );
    }
  }

  void _drawKaaba(Canvas canvas, Size size) {
    final body = Paint()..color = AppColors.ink;
    final gold = Paint()..color = accent;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .22,
        size.height * .24,
        size.width * .56,
        size.height * .54,
      ),
      Radius.circular(size.width * .08),
    );
    canvas.drawRRect(rect, body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .27,
          size.height * .35,
          size.width * .46,
          size.height * .10,
        ),
        Radius.circular(size.width * .025),
      ),
      gold,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .48,
        size.height * .52,
        size.width * .10,
        size.height * .26,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  void _drawQuran(Canvas canvas, Size size) {
    final stroke = _stroke(size);
    final fill = Paint()..color = primary.withValues(alpha: 0.10);
    final left = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .12,
        size.height * .22,
        size.width * .36,
        size.height * .56,
      ),
      Radius.circular(size.width * .06),
    );
    final right = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .52,
        size.height * .22,
        size.width * .36,
        size.height * .56,
      ),
      Radius.circular(size.width * .06),
    );
    canvas.drawRRect(left, fill);
    canvas.drawRRect(right, fill);
    canvas.drawRRect(left, stroke);
    canvas.drawRRect(right, stroke);
    canvas.drawLine(
      Offset(size.width * .5, size.height * .25),
      Offset(size.width * .5, size.height * .82),
      stroke,
    );
    for (final y in [.40, .52, .64]) {
      canvas.drawLine(
        Offset(size.width * .20, size.height * y),
        Offset(size.width * .40, size.height * y),
        stroke,
      );
      canvas.drawLine(
        Offset(size.width * .60, size.height * y),
        Offset(size.width * .80, size.height * y),
        stroke,
      );
    }
  }

  void _drawTasbih(Canvas canvas, Size size) {
    final bead = Paint()..color = primary;
    final line = _stroke(size)..color = primary.withValues(alpha: 0.5);
    final center = Offset(size.width * .50, size.height * .52);
    final radius = size.width * .30;
    for (var i = 0; i < 12; i++) {
      final angle = (i * 28 + 22) * math.pi / 180;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(p, size.width * .045, bead);
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      .2,
      5.5,
      false,
      line,
    );
    canvas.drawCircle(
      Offset(size.width * .50, size.height * .17),
      size.width * .050,
      Paint()..color = accent,
    );
    canvas.drawLine(
      Offset(size.width * .50, size.height * .22),
      Offset(size.width * .50, size.height * .36),
      line,
    );
  }

  void _drawCrescent(Canvas canvas, Size size) {
    final moon = Paint()..color = primary;
    canvas.drawCircle(
      Offset(size.width * .44, size.height * .48),
      size.width * .26,
      moon,
    );
    canvas.drawCircle(
      Offset(size.width * .54, size.height * .42),
      size.width * .25,
      Paint()..color = Colors.white,
    );
    _drawStar(
      canvas,
      Offset(size.width * .72, size.height * .30),
      size.width * .075,
      accent,
    );
  }

  void _drawCompass(Canvas canvas, Size size) {
    final stroke = _stroke(size);
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      size.width * .34,
      Paint()..color = primary.withValues(alpha: 0.10),
    );
    canvas.drawCircle(center, size.width * .34, stroke);
    final arrow = Path()
      ..moveTo(size.width * .58, size.height * .18)
      ..lineTo(size.width * .48, size.height * .54)
      ..lineTo(size.width * .30, size.height * .70)
      ..lineTo(size.width * .42, size.height * .34)
      ..close();
    canvas.drawPath(arrow, Paint()..color = primary);
    canvas.drawCircle(center, size.width * .045, Paint()..color = accent);
  }

  void _drawWallpaper(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .20,
        size.height * .12,
        size.width * .60,
        size.height * .76,
      ),
      Radius.circular(size.width * .12),
    );
    canvas.drawRRect(rect, Paint()..color = primary.withValues(alpha: 0.14));
    canvas.drawRRect(rect, _stroke(size));
    canvas.drawCircle(
      Offset(size.width * .36, size.height * .34),
      size.width * .08,
      Paint()..color = accent,
    );
    final wave = Path()
      ..moveTo(size.width * .24, size.height * .72)
      ..quadraticBezierTo(
        size.width * .42,
        size.height * .54,
        size.width * .56,
        size.height * .68,
      )
      ..quadraticBezierTo(
        size.width * .66,
        size.height * .78,
        size.width * .76,
        size.height * .62,
      );
    canvas.drawPath(wave, _stroke(size));
  }

  void _drawKnowledge(Canvas canvas, Size size) {
    _drawQuran(canvas, size);
    canvas.drawCircle(
      Offset(size.width * .74, size.height * .26),
      size.width * .10,
      Paint()..color = accent,
    );
    canvas.drawLine(
      Offset(size.width * .74, size.height * .12),
      Offset(size.width * .74, size.height * .40),
      _stroke(size),
    );
  }

  void _drawFriday(Canvas canvas, Size size) {
    final stroke = _stroke(size);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .18,
        size.height * .24,
        size.width * .64,
        size.height * .56,
      ),
      Radius.circular(size.width * .09),
    );
    canvas.drawRRect(rect, Paint()..color = primary.withValues(alpha: 0.10));
    canvas.drawRRect(rect, stroke);
    canvas.drawLine(
      Offset(size.width * .18, size.height * .42),
      Offset(size.width * .82, size.height * .42),
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * .36, size.height * .62),
      size.width * .055,
      Paint()..color = accent,
    );
    canvas.drawCircle(
      Offset(size.width * .52, size.height * .62),
      size.width * .055,
      Paint()..color = primary,
    );
  }

  void _drawEsma(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = _stroke(size)..strokeWidth = size.width * .035;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final p =
          center + Offset(math.cos(angle), math.sin(angle)) * size.width * .23;
      canvas.drawOval(
        Rect.fromCenter(
          center: p,
          width: size.width * .15,
          height: size.width * .28,
        ),
        Paint()..color = primary.withValues(alpha: 0.16),
      );
    }
    canvas.drawCircle(center, size.width * .17, Paint()..color = Colors.white);
    canvas.drawCircle(center, size.width * .17, stroke);
    _drawStar(canvas, center, size.width * .07, accent);
  }

  Paint _stroke(Size size) {
    return Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, size.width * .045)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * .44;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _AppIllustrationPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.primary != primary ||
        oldDelegate.accent != accent;
  }
}
