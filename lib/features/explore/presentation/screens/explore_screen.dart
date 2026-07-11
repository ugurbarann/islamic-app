import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/app_feature_icon.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Keşfet',
      body: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1,
        child: PremiumScrollView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Kıble, dualar, bilgiler ve manevi yolculuğunuza rehberlik eden araçlar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                      height: 1.28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _RoundExploreButton(
                  icon: Icons.search_rounded,
                  onTap: () => context.push('/quran/search'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ExploreSectionTitle(
              title: 'Kategoriler',
              action: 'Tümünü Gör',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tüm keşif kategorileri bu ekranda.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ExploreItem.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 9,
                crossAxisSpacing: 9,
                childAspectRatio: .76,
              ),
              itemBuilder: (context, index) =>
                  _ExploreCategoryCard(item: _ExploreItem.items[index]),
            ),
            const SizedBox(height: 12),
            const _ExploreQuoteCard(),
          ],
        ),
      ),
    );
  }
}

class _ExploreSectionTitle extends StatelessWidget {
  const _ExploreSectionTitle({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Tümünü Gör'),
              SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExploreCategoryCard extends StatelessWidget {
  const _ExploreCategoryCard({required this.item});

  final _ExploreItem item;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
      shadow: false,
      color: item.softColor.withValues(alpha: .55),
      onTap: () => context.push(item.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6, bottom: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppFeatureIcon(kind: item.icon, size: 32, iconSize: 20),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 9.4,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .76),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: item.primary,
                      size: 18,
                    ),
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

class _ExploreQuoteCard extends StatelessWidget {
  const _ExploreQuoteCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 28,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      shadow: false,
      child: Row(
        children: [
          const AppFeatureIcon(
            kind: AppFeatureIconKind.quran,
            size: 42,
            iconSize: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Şüphesiz zikir, kalpleri huzura kavuşturur.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rad Suresi, 28. Ayet',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              size: const Size(92, 70),
              painter: _QuotePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundExploreButton extends StatelessWidget {
  const _RoundExploreButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .78),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _ExploreItem {
  const _ExploreItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.primary,
    required this.softColor,
  });

  final String title;
  final String subtitle;
  final String route;
  final AppFeatureIconKind icon;
  final Color primary;
  final Color softColor;

  static const items = [
    _ExploreItem(
      title: 'İslami Bilgiler',
      subtitle: 'Kısa yazılar ve tarih',
      route: '/knowledge',
      icon: AppFeatureIconKind.knowledge,
      primary: Color(0xFF2F9D75),
      softColor: Color(0xFFEFFAF5),
    ),
    _ExploreItem(
      title: 'Cuma Hatırlatıcısı',
      subtitle: 'Cuma gününü kaçırma',
      route: '/friday-reminder',
      icon: AppFeatureIconKind.calendar,
      primary: Color(0xFFD5B137),
      softColor: Color(0xFFFFFAE8),
    ),
    _ExploreItem(
      title: 'Yakındaki Camiler',
      subtitle: 'En yakın camiler',
      route: '/mosques',
      icon: AppFeatureIconKind.mosque,
      primary: Color(0xFF1B8B9A),
      softColor: Color(0xFFEAFBFD),
    ),
    _ExploreItem(
      title: 'Esmaül Hüsna',
      subtitle: 'Allah’ın 99 ismi',
      route: '/knowledge/esmaul-husna',
      icon: AppFeatureIconKind.esma,
      primary: Color(0xFFD4A12E),
      softColor: Color(0xFFFFF7E4),
    ),
    _ExploreItem(
      title: 'Duvar Kağıtları',
      subtitle: 'İslami duvar kağıtları',
      route: '/wallpapers',
      icon: AppFeatureIconKind.wallpaper,
      primary: Color(0xFFC56A5A),
      softColor: Color(0xFFFFF1ED),
    ),
    _ExploreItem(
      title: 'Namaz Vakitleri',
      subtitle: 'Günlük vakitler ve hatırlatıcılar',
      route: '/prayer',
      icon: AppFeatureIconKind.calendar,
      primary: Color(0xFF236FCB),
      softColor: Color(0xFFEAF5FF),
    ),
    _ExploreItem(
      title: 'Kıble',
      subtitle: 'Kıble yönünü bulun',
      route: '/qibla',
      icon: AppFeatureIconKind.kaaba,
      primary: Color(0xFF7655D8),
      softColor: Color(0xFFF3EEFF),
    ),
    _ExploreItem(
      title: 'Dualar',
      subtitle: 'Dua içerikleri',
      route: '/duas',
      icon: AppFeatureIconKind.dua,
      primary: Color(0xFF2EAA83),
      softColor: Color(0xFFEFFFF9),
    ),
    _ExploreItem(
      title: 'Tesbih',
      subtitle: 'Zikir sayacı',
      route: '/tasbih',
      icon: AppFeatureIconKind.tasbih,
      primary: Color(0xFF236FCB),
      softColor: Color(0xFFEAF5FF),
    ),
  ];
}

class _QuotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final book = Paint()
      ..color = const Color(0xFF9BCBFF).withValues(alpha: .26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 20, size.width * .44, 32),
        const Radius.circular(8),
      ),
      book,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .48, 20, size.width * .44, 32),
        const Radius.circular(8),
      ),
      book,
    );
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .62),
      16,
      Paint()..color = const Color(0xFFF4BD52).withValues(alpha: .32),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
