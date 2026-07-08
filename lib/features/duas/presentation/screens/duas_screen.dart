import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/dua_category.dart';
import '../controllers/dua_controller.dart';

class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          bottom: false,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1,
            child: categoriesAsync.when(
              data: (categories) => ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 150),
                itemCount: categories.length + 1,
                separatorBuilder: (context, index) =>
                    SizedBox(height: index == 0 ? 12 : 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _DuasHeader(
                      onFavorites: () => context.push('/duas/favorites'),
                    );
                  }

                  final category = categories[index - 1];
                  final style = _styleForCategory(category.id);
                  return _DuaCategoryCard(
                    category: category,
                    style: style,
                    onTap: () => context.push('/duas/category/${category.id}'),
                  );
                },
              ),
              loading: () => const PremiumStateView(
                title: 'Dualar yükleniyor',
                loading: true,
              ),
              error: (error, stackTrace) => PremiumStateView(
                title: 'Dualar yüklenemedi',
                message: error.toString(),
                icon: Icons.error_outline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DuasHeader extends StatelessWidget {
  const _DuasHeader({required this.onFavorites});

  final VoidCallback onFavorites;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: _DuaPainter())),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: SizedBox(
              width: 58,
              height: 58,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppShadows.soft,
                ),
                child: IconButton(
                  tooltip: 'Favori Dualar',
                  onPressed: onFavorites,
                  icon: const Icon(Icons.favorite_border_rounded),
                  color: AppColors.ink,
                  iconSize: 30,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 36,
            right: 86,
            child: Text(
              'Dualar',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.ink,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1.03,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 88,
            width: 250,
            child: Text(
              'Günlük hayatınıza huzur\nkatacak dualar.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.muted,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaCategoryCard extends StatelessWidget {
  const _DuaCategoryCard({
    required this.category,
    required this.style,
    required this.onTap,
  });

  final DuaCategory category;
  final _DuaCategoryStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      shadow: false,
      color: Colors.white.withValues(alpha: .92),
      onTap: onTap,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: style.softColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(style.icon, color: style.color, size: 25),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.duaCount} dua',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF506888),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class _DuaCategoryStyle {
  const _DuaCategoryStyle({
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final IconData icon;
  final Color color;
  final Color softColor;
}

_DuaCategoryStyle _styleForCategory(String id) {
  return switch (id) {
    'morning' => const _DuaCategoryStyle(
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFF1B64C6),
      softColor: Color(0xFFEAF4FF),
    ),
    'evening' => const _DuaCategoryStyle(
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFFA87536),
      softColor: Color(0xFFFFF3E8),
    ),
    'travel' => const _DuaCategoryStyle(
      icon: Icons.location_on_outlined,
      color: Color(0xFF2A9B78),
      softColor: Color(0xFFEAF9F3),
    ),
    'meal' => const _DuaCategoryStyle(
      icon: Icons.restaurant_rounded,
      color: Color(0xFF7556A8),
      softColor: Color(0xFFF3EDFF),
    ),
    'healing' => const _DuaCategoryStyle(
      icon: Icons.volunteer_activism_outlined,
      color: Color(0xFF657895),
      softColor: Color(0xFFF0F6FF),
    ),
    'exam' => const _DuaCategoryStyle(
      icon: Icons.school_outlined,
      color: Color(0xFFC36B92),
      softColor: Color(0xFFFFEDF5),
    ),
    _ => const _DuaCategoryStyle(
      icon: Icons.favorite_border_rounded,
      color: AppColors.primary,
      softColor: AppColors.primarySoft,
    ),
  };
}

class _DuaPainter extends CustomPainter {
  const _DuaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FC6FF).withValues(alpha: .15);
    final baseY = size.height * .98;

    canvas.drawCircle(Offset(size.width * .78, baseY - 95), 42, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .66, baseY - 78, size.width * .24, 66),
        const Radius.circular(14),
      ),
      paint,
    );

    for (final x in [size.width * .53, size.width * .69]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, baseY - 150, 16, 140),
          const Radius.circular(8),
        ),
        paint,
      );
      final path = Path()
        ..moveTo(x - 5, baseY - 150)
        ..lineTo(x + 8, baseY - 174)
        ..lineTo(x + 21, baseY - 150)
        ..close();
      canvas.drawPath(path, paint);
    }

    final crescent = Paint()
      ..color = const Color(0xFF76B3F7).withValues(alpha: .20);
    canvas.drawCircle(Offset(size.width * .82, baseY - 150), 18, crescent);
    canvas.drawCircle(
      Offset(size.width * .88, baseY - 155),
      18,
      Paint()..color = AppColors.sky.withValues(alpha: .88),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
