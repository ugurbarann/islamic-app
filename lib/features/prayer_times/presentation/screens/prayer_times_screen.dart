import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_feature_icon.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/next_prayer_info.dart';
import '../../domain/entities/prayer_name.dart';
import '../../domain/entities/prayer_notification_preference.dart';
import '../../domain/entities/prayer_time_day.dart';
import '../controllers/prayer_notification_controller.dart';
import '../controllers/prayer_times_controller.dart';
import '../widgets/prayer_time_formatters.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: Stack(
        children: [
          const _PrayerBackground(),
          SafeArea(
            bottom: false,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1,
              child: prayerTimesAsync.when(
                data: (prayerTimeDay) => _PrayerTimesContent(
                  prayerTimeDay: prayerTimeDay,
                  basePath: _basePrayerPath(context),
                ),
                loading: () => const PremiumStateView(
                  title: 'Namaz vakitleri yükleniyor',
                  loading: true,
                ),
                error: (error, stackTrace) => PremiumStateView(
                  title: 'Namaz vakitleri yüklenemedi',
                  message: error.toString(),
                  icon: Icons.error_outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _basePrayerPath(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return path.startsWith('/home/prayer') ? '/home/prayer' : '/prayer';
  }
}

class _PrayerTimesContent extends StatelessWidget {
  const _PrayerTimesContent({
    required this.prayerTimeDay,
    required this.basePath,
  });

  final PrayerTimeDay prayerTimeDay;
  final String basePath;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 118),
          sliver: SliverList.list(
            children: [
              _PrayerHeader(prayerTimeDay: prayerTimeDay, basePath: basePath),
              const SizedBox(height: 14),
              _NextPrayerHero(prayerTimeDay: prayerTimeDay),
              const SizedBox(height: 10),
              _DateStrip(prayerTimeDay: prayerTimeDay),
              const SizedBox(height: 10),
              for (final prayerName in PrayerName.values) ...[
                _PrayerTimeTileConsumer(
                  prayerName: prayerName,
                  time: prayerTimeDay.timeFor(prayerName),
                ),
                const SizedBox(height: 7),
              ],
              _SourceCard(prayerTimeDay: prayerTimeDay),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrayerHeader extends StatelessWidget {
  const _PrayerHeader({required this.prayerTimeDay, required this.basePath});

  final PrayerTimeDay prayerTimeDay;
  final String basePath;

  @override
  Widget build(BuildContext context) {
    final location = prayerTimeDay.location;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.canPop()) ...[
          _RoundHeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaz Vakitleri',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push('$basePath/location'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.text,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${location.city.name} / ${location.district.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _RoundHeaderButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => context.push('$basePath/notifications'),
        ),
        const SizedBox(width: 8),
        _RoundHeaderButton(
          icon: Icons.calendar_month_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bugünün namaz vakitleri açık.')),
            );
          },
        ),
      ],
    );
  }
}

class _NextPrayerHero extends ConsumerWidget {
  const _NextPrayerHero({required this.prayerTimeDay});

  final PrayerTimeDay prayerTimeDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayerAsync = ref.watch(nextPrayerInfoProvider);

    return nextPrayerAsync.when(
      data: (info) =>
          _NextPrayerHeroCard(prayerTimeDay: prayerTimeDay, info: info),
      loading: () => const GlassPanel(
        borderRadius: 28,
        shadow: false,
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Sıradaki namaz yükleniyor'),
          ],
        ),
      ),
      error: (error, stackTrace) => PremiumStateView(
        title: 'Sıradaki namaz yüklenemedi',
        message: error.toString(),
        icon: Icons.error_outline,
      ),
    );
  }
}

class _NextPrayerHeroCard extends StatelessWidget {
  const _NextPrayerHeroCard({required this.prayerTimeDay, required this.info});

  final PrayerTimeDay prayerTimeDay;
  final NextPrayerInfo info;

  @override
  Widget build(BuildContext context) {
    final progress = _progressFor(prayerTimeDay, info);

    return GlassPanel(
      borderRadius: 30,
      padding: EdgeInsets.zero,
      shadow: false,
      child: SizedBox(
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFF8FCFF),
                        Color(0xFFE8F4FF),
                        Color(0xFFCFE8FF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _PrayerHeroPainter()),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: .78),
                        Colors.white.withValues(alpha: .30),
                        Colors.white.withValues(alpha: .02),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sıradaki Namaz',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      info.nextPrayerName.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kalan Süre',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatRemaining(info.remaining),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 170,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: progress,
                          backgroundColor: const Color(0xFFD5E2F1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
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

  double _progressFor(PrayerTimeDay day, NextPrayerInfo info) {
    final current = info.currentPrayerName;
    if (current == null) {
      return 0;
    }
    final start = day.timeFor(current);
    final end = info.nextPrayerTime;
    final total = end.difference(start).inSeconds;
    if (total <= 0) {
      return 0;
    }
    final elapsed = DateTime.now().difference(start).inSeconds;
    return (elapsed / total).clamp(0, 1).toDouble();
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.prayerTimeDay});

  final PrayerTimeDay prayerTimeDay;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 25,
      padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
      shadow: false,
      child: Row(
        children: [
          const AppFeatureIcon(
            kind: AppFeatureIconKind.calendar,
            size: 38,
            iconSize: 23,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatFullDate(prayerTimeDay.date),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _weekday(prayerTimeDay.date),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bugünün vakitleri gösteriliyor.'),
                ),
              );
            },
            label: const Text('Takvime Git'),
            icon: const Icon(Icons.chevron_right_rounded),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeTileConsumer extends ConsumerWidget {
  const _PrayerTimeTileConsumer({required this.prayerName, required this.time});

  final PrayerName prayerName;
  final DateTime time;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(
      nextPrayerInfoProvider.select((value) {
        final info = value.asData?.value;
        return (current: info?.currentPrayerName, next: info?.nextPrayerName);
      }),
    );
    final preferenceAsync = ref.watch(prayerNotificationControllerProvider);
    final preference =
        preferenceAsync.asData?.value ??
        PrayerNotificationPreference.defaults();

    return _PrayerTimeTile(
      prayerName: prayerName,
      time: time,
      currentPrayerName: prayerState.current,
      nextPrayerName: prayerState.next,
      notificationsBusy: preferenceAsync.isLoading,
      notificationsEnabled: preference.isEnabled(prayerName),
      onNotificationTap:
          PrayerNotificationPreference.configurablePrayers.contains(prayerName)
          ? () => _toggleNotification(context, ref, preference)
          : null,
    );
  }

  Future<void> _toggleNotification(
    BuildContext context,
    WidgetRef ref,
    PrayerNotificationPreference preference,
  ) async {
    final enabled = preference.isEnabled(prayerName);
    final granted = await ref
        .read(prayerNotificationControllerProvider.notifier)
        .setPrayerEnabled(prayerName: prayerName, enabled: !enabled);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !granted
              ? 'Bildirim izni verilmedi.'
              : enabled
              ? '${prayerName.label} bildirimi kapatıldı.'
              : '${prayerName.label} bildirimi açıldı.',
        ),
      ),
    );
  }
}

class _PrayerTimeTile extends StatelessWidget {
  const _PrayerTimeTile({
    required this.prayerName,
    required this.time,
    required this.currentPrayerName,
    required this.nextPrayerName,
    required this.notificationsEnabled,
    required this.notificationsBusy,
    required this.onNotificationTap,
  });

  final PrayerName prayerName;
  final DateTime time;
  final PrayerName? currentPrayerName;
  final PrayerName? nextPrayerName;
  final bool notificationsEnabled;
  final bool notificationsBusy;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final isCurrent = prayerName == currentPrayerName;
    final isNext = prayerName == nextPrayerName;
    final accent = _accentFor(prayerName, isCurrent: isCurrent, isNext: isNext);
    final status = nextPrayerName == null
        ? ''
        : prayerStatusLabel(
            prayerName: prayerName,
            currentPrayerName: currentPrayerName,
            nextPrayerName: nextPrayerName!,
          );

    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
      shadow: false,
      color: isCurrent
          ? const Color(0xFFECEEFF)
          : isNext
          ? const Color(0xFFF4F8FF)
          : Colors.white.withValues(alpha: .86),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: .13),
            ),
            child: Icon(_iconFor(prayerName), color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: isCurrent || isNext
                        ? FontWeight.w900
                        : FontWeight.w700,
                  ),
                ),
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formatClock(time),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          _NotificationButton(
            enabled: notificationsEnabled,
            busy: notificationsBusy,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PrayerName prayerName) {
    return switch (prayerName) {
      PrayerName.imsak => Icons.wb_twilight_outlined,
      PrayerName.sunrise => Icons.wb_sunny_outlined,
      PrayerName.dhuhr => Icons.light_mode_outlined,
      PrayerName.asr => Icons.wb_twilight_outlined,
      PrayerName.maghrib => Icons.wb_twilight_outlined,
      PrayerName.isha => Icons.nightlight_round,
    };
  }

  Color _accentFor(
    PrayerName prayerName, {
    required bool isCurrent,
    required bool isNext,
  }) {
    if (isCurrent) {
      return AppColors.primary;
    }
    if (isNext) {
      return const Color(0xFFB64DCC);
    }
    return switch (prayerName) {
      PrayerName.imsak => const Color(0xFFE4A930),
      PrayerName.sunrise => const Color(0xFFE9A83B),
      PrayerName.dhuhr => const Color(0xFFE7B13C),
      PrayerName.asr => const Color(0xFF5E7DE8),
      PrayerName.maghrib => const Color(0xFFBD55C9),
      PrayerName.isha => AppColors.primary,
    };
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (busy && onTap != null) {
      return const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      tooltip: enabled ? 'Bildirimi kapat' : 'Bildirimi aç',
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        enabled
            ? Icons.notifications_none_rounded
            : Icons.notifications_off_outlined,
        color: enabled ? AppColors.primary : AppColors.muted,
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.prayerTimeDay});

  final PrayerTimeDay prayerTimeDay;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(15, 13, 14, 13),
      shadow: false,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vakitler Diyanet İşleri Başkanlığı verilerine göre hazırlanmıştır.',
            ),
          ),
        );
      },
      child: Row(
        children: [
          const AppFeatureIcon(
            kind: AppFeatureIconKind.mosque,
            size: 38,
            iconSize: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vakitler Diyanet İşleri Başkanlığı verilerine göre hazırlanmıştır.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _RoundHeaderButton extends StatelessWidget {
  const _RoundHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .86),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.ink, size: 25),
        ),
      ),
    );
  }
}

class _PrayerBackground extends StatelessWidget {
  const _PrayerBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF6FF), Color(0xFFF8FCFF), Color(0xFFEFF8FF)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _PrayerHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final right = size.width;
    final bottom = size.height;
    final mosque = Paint()..color = Colors.white.withValues(alpha: .72);
    final shade = Paint()
      ..color = const Color(0xFF8EBFF5).withValues(alpha: .28);

    canvas.drawCircle(
      Offset(right * .74, bottom * .28),
      31,
      Paint()..color = Colors.white.withValues(alpha: .94),
    );
    canvas.drawCircle(
      Offset(right * .77, bottom * .25),
      31,
      Paint()..color = const Color(0xFFCFE8FF),
    );

    final baseY = bottom * .84;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(right * .58, baseY - 66, right * .36, 66),
        const Radius.circular(12),
      ),
      mosque,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(right * .76, baseY - 66),
        width: right * .28,
        height: 125,
      ),
      3.14,
      3.14,
      true,
      mosque,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(right * .76, baseY - 66),
        width: right * .28,
        height: 125,
      ),
      3.14,
      3.14,
      false,
      shade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    for (final x in [0.52, 0.92]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(right * x, baseY - 150, 15, 150),
          const Radius.circular(8),
        ),
        mosque,
      );
      canvas.drawPath(
        Path()
          ..moveTo(right * x - 4, baseY - 150)
          ..lineTo(right * x + 7.5, baseY - 184)
          ..lineTo(right * x + 19, baseY - 150)
          ..close(),
        mosque,
      );
    }

    for (final x in [0.62, 0.73, 0.84]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(right * x, baseY - 38, 16, 38),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFFAACFFF).withValues(alpha: .30),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatFullDate(DateTime date) {
  return '${date.day} ${_month(date.month)} ${date.year}';
}

String _weekday(DateTime date) {
  const weekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  return weekdays[date.weekday - 1];
}

String _month(int month) {
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
  return months[month - 1];
}
