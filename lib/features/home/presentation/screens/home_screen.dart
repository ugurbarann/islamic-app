import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_illustrations.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../friday_reminder/presentation/controllers/friday_reminder_controller.dart';
import '../../../prayer_times/domain/entities/next_prayer_info.dart';
import '../../../prayer_times/domain/entities/prayer_name.dart';
import '../../../prayer_times/domain/entities/prayer_time_day.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../../../prayer_times/presentation/widgets/prayer_time_formatters.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _ink = Color(0xFF0B2854);
  static const _blue = Color(0xFF2478E8);
  static const _muted = Color(0xFF6D7F9C);
  static const _page = Color(0xFFF3FAFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFriday = ref.watch(isFridayProvider);

    return Scaffold(
      backgroundColor: _page,
      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
            bottom: false,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 104),
                    sliver: SliverList.list(
                      children: [
                        const _HeaderSection(),
                        const SizedBox(height: 6),
                        if (isFriday) ...[
                          const _FridayBanner(),
                          const SizedBox(height: 12),
                        ],
                        const _NextPrayerCardConsumer(),
                        const SizedBox(height: 10),
                        const _PrayerTimesCardConsumer(),
                        const SizedBox(height: 14),
                        const _QuickActionsPanel(),
                        const SizedBox(height: 16),
                        const _ExploreSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4FAFF), Color(0xFFFFFFFF), Color(0xFFF2FAFF)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CircleIconButton(
              icon: Icons.person_outline_rounded,
              onPressed: () => context.go('/settings'),
            ),
            const Spacer(),
            _CircleIconButton(
              icon: Icons.notifications_none_rounded,
              onPressed: () => context.push('/home/prayer/notifications'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Esselamü Aleyküm',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: HomeScreen._ink,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Hayırlı akşamlar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HomeScreen._muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.nightlight_round,
              color: Color(0xFF3B8AE8),
              size: 17,
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .86),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: HomeScreen._ink, size: 18),
        ),
      ),
    );
  }
}

class _FridayBanner extends StatelessWidget {
  const _FridayBanner();

  @override
  Widget build(BuildContext context) {
    return const GlassPanel(
      borderRadius: 22,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shadow: false,
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: HomeScreen._blue),
          SizedBox(width: 10),
          Expanded(child: Text('Cumanız mübarek olsun.')),
        ],
      ),
    );
  }
}

class _NextPrayerCardConsumer extends ConsumerWidget {
  const _NextPrayerCardConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayerAsync = ref.watch(nextPrayerInfoProvider);
    return nextPrayerAsync.when(
      data: (value) => _NextPrayerCard(nextPrayerInfo: value),
      loading: () => const _StatusCard(label: 'Sıradaki namaz yükleniyor'),
      error: (error, stackTrace) =>
          _StatusCard(label: 'Sıradaki namaz yüklenemedi: $error'),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.nextPrayerInfo});

  final NextPrayerInfo nextPrayerInfo;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: EdgeInsets.zero,
      shadow: false,
      onTap: () => context.push('/home/prayer'),
      child: SizedBox(
        height: 116,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFFFF9F2),
                        Color(0xFFFFEAD8),
                        Color(0xFFD6EAFF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _SunsetMosquePainter()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox.expand(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Text(
                                'Sıradaki Namaz',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: const Color(0xFF23517C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 24,
                              child: Text(
                                nextPrayerInfo.nextPrayerName.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: HomeScreen._ink,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 58,
                              child: Text(
                                'Kalan Süre',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: HomeScreen._muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 74,
                              child: Text(
                                formatRemaining(nextPrayerInfo.remaining),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: HomeScreen._blue,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .82),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: HomeScreen._blue,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerTimesCardConsumer extends ConsumerWidget {
  const _PrayerTimesCardConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final highlightedPrayer = ref.watch(
      nextPrayerInfoProvider.select(
        (value) => value.asData?.value.nextPrayerName,
      ),
    );

    return prayerTimesAsync.when(
      data: (day) => _PrayerTimesCard(
        prayerTimeDay: day,
        highlightedPrayer: highlightedPrayer,
      ),
      loading: () => const _StatusCard(label: 'Namaz vakitleri yükleniyor'),
      error: (error, stackTrace) =>
          _StatusCard(label: 'Namaz vakitleri yüklenemedi: $error'),
    );
  }
}

class _PrayerTimesCard extends StatelessWidget {
  const _PrayerTimesCard({
    required this.prayerTimeDay,
    required this.highlightedPrayer,
  });

  final PrayerTimeDay prayerTimeDay;
  final PrayerName? highlightedPrayer;

  @override
  Widget build(BuildContext context) {
    final location = prayerTimeDay.location;

    return GlassPanel(
      borderRadius: 26,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
      shadow: false,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: HomeScreen._blue,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${location.city.name}, Türkiye',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: HomeScreen._ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.district.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: HomeScreen._muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(prayerTimeDay.date),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: HomeScreen._muted,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final prayerName in PrayerName.values)
                Expanded(
                  child: _PrayerTimeCell(
                    prayerName: prayerName,
                    time: prayerTimeDay.timeFor(prayerName),
                    isHighlighted: highlightedPrayer == prayerName,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    const weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}\n${weekdays[date.weekday - 1]}';
  }
}

class _PrayerTimeCell extends StatelessWidget {
  const _PrayerTimeCell({
    required this.prayerName,
    required this.time,
    required this.isHighlighted,
  });

  final PrayerName prayerName;
  final DateTime time;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 1),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFFEAF4FF).withValues(alpha: .92)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prayerName.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isHighlighted ? HomeScreen._blue : HomeScreen._muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            _iconForPrayer(prayerName),
            color: prayerName == PrayerName.isha
                ? const Color(0xFF6B7890)
                : const Color(0xFFF2AF35),
            size: 20,
          ),
          const SizedBox(height: 5),
          Text(
            formatClock(time),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isHighlighted ? HomeScreen._blue : HomeScreen._ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForPrayer(PrayerName prayerName) {
    return switch (prayerName) {
      PrayerName.imsak => Icons.wb_twilight_outlined,
      PrayerName.sunrise => Icons.wb_sunny_outlined,
      PrayerName.dhuhr => Icons.light_mode_outlined,
      PrayerName.asr => Icons.light_mode_outlined,
      PrayerName.maghrib => Icons.wb_twilight_outlined,
      PrayerName.isha => Icons.nightlight_round,
    };
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel();

  @override
  Widget build(BuildContext context) {
    const actions = [
      _QuickAction('Kur\'an', AppIllustrationKind.quran, '/quran'),
      _QuickAction('Dualar', AppIllustrationKind.crescent, '/duas'),
      _QuickAction('Tesbih', AppIllustrationKind.tasbih, '/tasbih'),
      _QuickAction('Kıble', AppIllustrationKind.compass, '/qibla'),
      _QuickAction('Camiler', AppIllustrationKind.mosque, '/mosques'),
    ];

    return GlassPanel(
      borderRadius: 26,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kısayollar',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HomeScreen._ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final action in actions)
                Expanded(child: _QuickActionTile(action: action)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.route);

  final String label;
  final AppIllustrationKind icon;
  final String route;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push(action.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: _softColor(action.icon),
              ),
              child: Center(
                child: AppIllustration(kind: action.icon, size: 23),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: HomeScreen._ink,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _softColor(AppIllustrationKind kind) {
    return switch (kind) {
      AppIllustrationKind.quran => const Color(0xFFE3F3FF),
      AppIllustrationKind.crescent => const Color(0xFFE9FAF2),
      AppIllustrationKind.tasbih => const Color(0xFFFFF5E4),
      AppIllustrationKind.compass => const Color(0xFFF5EAFE),
      AppIllustrationKind.mosque => const Color(0xFFEFF8F1),
      _ => const Color(0xFFEAF4FF),
    };
  }
}

class _ExploreSection extends StatelessWidget {
  const _ExploreSection();

  @override
  Widget build(BuildContext context) {
    const items = [
      _ExploreItem(
        title: 'Esmaül Hüsna',
        subtitle: 'Allah’ın 99 ismi',
        icon: AppIllustrationKind.esma,
        route: '/knowledge/esmaul-husna',
        colors: [Color(0xFFEFF8F1), Color(0xFFDDEFE5)],
      ),
      _ExploreItem(
        title: 'Yakındaki Camiler',
        subtitle: 'Çevrendeki camileri keşfet.',
        icon: AppIllustrationKind.mosque,
        route: '/mosques',
        colors: [Color(0xFFFFF4E6), Color(0xFFFFE2BD)],
      ),
      _ExploreItem(
        title: 'Huzur Duvar Kağıtları',
        subtitle: 'Sakinleştirici arka planlar',
        icon: AppIllustrationKind.wallpaper,
        route: '/wallpapers',
        colors: [Color(0xFFDBECFF), Color(0xFF8DB9EA)],
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Keşfet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: HomeScreen._ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/explore'),
              child: const Text('Tümünü Gör'),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: HomeScreen._blue,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(child: _ExploreCard(item: items[i])),
              if (i != items.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _ExploreItem {
  const _ExploreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final AppIllustrationKind icon;
  final String route;
  final List<Color> colors;
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.item});

  final _ExploreItem item;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 18,
      padding: EdgeInsets.zero,
      shadow: false,
      onTap: () => context.push(item.route),
      child: SizedBox(
        height: 84,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ExploreCardPainter(kind: item.icon),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: AppIllustration(
                    kind: item.icon,
                    size: item.icon == AppIllustrationKind.wallpaper ? 23 : 25,
                    primary: item.icon == AppIllustrationKind.wallpaper
                        ? Colors.white
                        : AppColors.primary,
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 8,
                  bottom: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: HomeScreen._ink,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: HomeScreen._muted,
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .84),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: HomeScreen._blue,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreCardPainter extends CustomPainter {
  const _ExploreCardPainter({required this.kind});

  final AppIllustrationKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case AppIllustrationKind.esma:
        _paintEsma(canvas, size);
      case AppIllustrationKind.mosque:
        _paintMosque(canvas, size);
      case AppIllustrationKind.wallpaper:
        _paintWallpaper(canvas, size);
      default:
        _paintSoftMotif(canvas, size);
    }
  }

  void _paintEsma(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFF5CAE78).withValues(alpha: .45);
    final center = Offset(size.width * .50, size.height * .35);
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * .52);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: size.width * .42,
            height: size.width * .18,
          ),
          const Radius.circular(18),
        ),
        paint,
      );
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      size.width * .12,
      Paint()..color = Colors.white.withValues(alpha: .42),
    );
  }

  void _paintMosque(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE3A543).withValues(alpha: .42);
    final baseY = size.height * .58;
    canvas.drawCircle(Offset(size.width * .48, baseY), size.width * .18, paint);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .28,
        baseY,
        size.width * .40,
        size.height * .14,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .70,
        size.height * .25,
        size.width * .045,
        size.height * .45,
      ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .722, size.height * .13)
        ..lineTo(size.width * .68, size.height * .27)
        ..lineTo(size.width * .765, size.height * .27)
        ..close(),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .30),
      4,
      Paint()..color = Colors.white.withValues(alpha: .74),
    );
  }

  void _paintWallpaper(Canvas canvas, Size size) {
    final moonPaint = Paint()..color = Colors.white.withValues(alpha: .88);
    canvas.drawCircle(
      Offset(size.width * .30, size.height * .24),
      13,
      moonPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .37, size.height * .21),
      13,
      Paint()..color = const Color(0xFF8DB9EA),
    );
    final far = Paint()..color = const Color(0xFF477DB7).withValues(alpha: .50);
    final near = Paint()
      ..color = const Color(0xFF2567A7).withValues(alpha: .50);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * .62)
        ..quadraticBezierTo(
          size.width * .25,
          size.height * .44,
          size.width * .48,
          size.height * .62,
        )
        ..quadraticBezierTo(
          size.width * .68,
          size.height * .80,
          size.width,
          size.height * .54,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      far,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * .74)
        ..quadraticBezierTo(
          size.width * .30,
          size.height * .55,
          size.width * .58,
          size.height * .74,
        )
        ..quadraticBezierTo(
          size.width * .78,
          size.height * .86,
          size.width,
          size.height * .66,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      near,
    );
  }

  void _paintSoftMotif(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * .76, size.height * .24),
      18,
      Paint()..color = Colors.white.withValues(alpha: .25),
    );
  }

  @override
  bool shouldRepaint(covariant _ExploreCardPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 22,
      shadow: false,
      child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class _SunsetMosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = const Color(0xFF7AA6D8).withValues(alpha: .64);
    final pale = Paint()..color = Colors.white.withValues(alpha: .42);
    final right = size.width;
    final bottom = size.height;

    canvas.drawCircle(
      Offset(right * .87, bottom * .31),
      18,
      Paint()..color = Colors.white.withValues(alpha: .38),
    );
    canvas.drawCircle(
      Offset(right * .91, bottom * .28),
      18,
      Paint()..color = const Color(0xFFFFE8D7).withValues(alpha: .80),
    );

    final domeRect = Rect.fromLTWH(right * .62, bottom * .35, 112, 92);
    canvas.drawArc(domeRect, 3.14, 3.14, true, base);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(right * .61, bottom * .62, 122, 38),
        const Radius.circular(8),
      ),
      base,
    );
    canvas.drawRect(Rect.fromLTWH(right * .75, bottom * .20, 10, 72), base);
    canvas.drawCircle(Offset(right * .755, bottom * .18), 6, base);
    canvas.drawPath(
      Path()
        ..moveTo(right * .755, bottom * .08)
        ..lineTo(right * .735, bottom * .20)
        ..lineTo(right * .775, bottom * .20)
        ..close(),
      base,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(right * .50, bottom * .72, 230, 36),
        const Radius.circular(20),
      ),
      pale,
    );

    final bird = Paint()
      ..color = const Color(0xFF5B7C9F).withValues(alpha: .58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final p in const [Offset(.49, .39), Offset(.55, .31)]) {
      final cx = size.width * p.dx;
      final cy = size.height * p.dy;
      canvas.drawPath(
        Path()
          ..moveTo(cx - 7, cy)
          ..quadraticBezierTo(cx, cy - 5, cx + 7, cy),
        bird,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
