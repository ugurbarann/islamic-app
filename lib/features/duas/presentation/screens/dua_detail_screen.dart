import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/dua_controller.dart';

class DuaDetailScreen extends ConsumerWidget {
  const DuaDetailScreen({required this.duaId, super.key});

  final String duaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duaAsync = ref.watch(duaDetailProvider(duaId));
    final favoriteDuasAsync = ref.watch(favoriteDuasControllerProvider);

    return PremiumScaffold(
      title: 'Dua Detayı',
      body: duaAsync.when(
        data: (dua) {
          final isFavorite = favoriteDuasAsync.maybeWhen(
            data: (duas) => duas.any((item) => item.id == dua.id),
            orElse: () => false,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
            children: [
              GlassPanel(
                borderRadius: 28,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _DuaDetailPatternPainter(),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dua.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              tooltip: isFavorite
                                  ? 'Favorilerden kaldır'
                                  : 'Favorilere ekle',
                              onPressed: () {
                                ref
                                    .read(
                                      favoriteDuasControllerProvider.notifier,
                                    )
                                    .toggleFavorite(dua);
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                              ),
                            ),
                          ],
                        ),
                        if (dua.arabicText != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            dua.arabicText!,
                            textAlign: TextAlign.right,
                            style: AppTypography.arabic(context),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                        if (dua.turkishTransliteration != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Okunuş',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(dua.turkishTransliteration!),
                        ],
                        const SizedBox(height: 18),
                        Text(
                          dua.turkishText,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.text,
                                fontSize: 17,
                                height: 1.55,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () =>
            const PremiumStateView(title: 'Dua yükleniyor', loading: true),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Dua yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _DuaDetailPatternPainter extends CustomPainter {
  const _DuaDetailPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..color = AppColors.primary.withValues(alpha: .055)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = AppColors.primary.withValues(alpha: .075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final baseY = size.height - 4;
    final centerX = size.width * .78;

    canvas.drawCircle(Offset(centerX, baseY - 58), 46, blue);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 54, baseY - 58, 108, 64),
        const Radius.circular(18),
      ),
      blue,
    );

    for (final x in [size.width * .58, size.width * .91]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, baseY - 118, 12, 118),
          const Radius.circular(8),
        ),
        blue,
      );
      final tip = Path()
        ..moveTo(x - 5, baseY - 118)
        ..lineTo(x + 6, baseY - 140)
        ..lineTo(x + 17, baseY - 118)
        ..close();
      canvas.drawPath(tip, blue);
    }

    final crescentCenter = Offset(size.width * .86, 44);
    canvas.drawCircle(crescentCenter, 16, line);
    canvas.drawCircle(
      crescentCenter.translate(7, -4),
      16,
      Paint()..color = Colors.white.withValues(alpha: .72),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
