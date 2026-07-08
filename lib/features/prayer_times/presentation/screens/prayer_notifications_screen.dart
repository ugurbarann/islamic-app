import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/prayer_name.dart';
import '../../domain/entities/prayer_notification_preference.dart';
import '../controllers/prayer_notification_controller.dart';

class PrayerNotificationsScreen extends ConsumerWidget {
  const PrayerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceAsync = ref.watch(prayerNotificationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      body: Stack(
        children: [
          const _NotificationBackground(),
          SafeArea(
            bottom: false,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1,
              child: preferenceAsync.when(
                data: (preference) => _NotificationBody(preference: preference),
                loading: () => const PremiumStateView(
                  title: 'Bildirim tercihleri yükleniyor',
                  loading: true,
                ),
                error: (error, stackTrace) => PremiumStateView(
                  title: 'Bildirim tercihleri yüklenemedi',
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
}

class _NotificationBody extends ConsumerWidget {
  const _NotificationBody({required this.preference});

  final PrayerNotificationPreference preference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 112),
          sliver: SliverList.list(
            children: [
              const _Header(),
              const SizedBox(height: 8),
              const _IntroCard(),
              const SizedBox(height: 12),
              Text(
                'Bildirim zamanı',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              _OffsetSelector(preference: preference),
              const SizedBox(height: 9),
              for (final prayerName in PrayerName.values) ...[
                _PrayerNotificationTile(
                  prayerName: prayerName,
                  preference: preference,
                ),
                const SizedBox(height: 5),
              ],
              const SizedBox(height: 8),
              const _InfoCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.ink,
            iconSize: 24,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Namaz Bildirimleri',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      shadow: false,
      color: Colors.white.withValues(alpha: .92),
      child: Row(
        children: [
          _RoundIcon(
            icon: Icons.notifications_none_rounded,
            color: AppColors.ink,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Namaz hatırlatma zamanı',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Seçtiğiniz vakitler için yerel bildirim planlanır.\nGerçek vakitler cache ile kullanılır.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontSize: 11,
                    height: 1.30,
                    fontWeight: FontWeight.w600,
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

class _OffsetSelector extends ConsumerWidget {
  const _OffsetSelector({required this.preference});

  final PrayerNotificationPreference preference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const items = [
      (value: 0, label: 'Vaktinde'),
      (value: 15, label: '15 dk'),
      (value: 30, label: '30 dk'),
      (value: 60, label: '1 saat'),
    ];

    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.all(6),
      shadow: false,
      color: Colors.white.withValues(alpha: .95),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: _OffsetButton(
                label: items[i].label,
                selected: preference.reminderOffsetMinutes == items[i].value,
                onTap: () => ref
                    .read(prayerNotificationControllerProvider.notifier)
                    .setReminderOffsetMinutes(items[i].value),
              ),
            ),
            if (i != items.length - 1)
              Container(
                width: 1,
                height: 34,
                color: AppColors.primary.withValues(alpha: .14),
              ),
          ],
        ],
      ),
    );
  }
}

class _OffsetButton extends StatelessWidget {
  const _OffsetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? const Color(0xFFE7F0FF) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected ? AppColors.primary : AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerNotificationTile extends ConsumerWidget {
  const _PrayerNotificationTile({
    required this.prayerName,
    required this.preference,
  });

  final PrayerName prayerName;
  final PrayerNotificationPreference preference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = preference.isEnabled(prayerName);

    return GlassPanel(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(13, 7, 12, 7),
      shadow: false,
      color: Colors.white.withValues(alpha: .94),
      child: Row(
        children: [
          _RoundIcon(icon: _iconFor(prayerName), color: _colorFor(prayerName)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  preference.reminderOffsetMinutes == 0
                      ? 'Vaktinde bildir'
                      : '${_offsetText(preference.reminderOffsetMinutes)} önce bildir',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: .72,
            child: Switch(
              value: enabled,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD2D3DA),
              onChanged: (value) async {
                final granted = await ref
                    .read(prayerNotificationControllerProvider.notifier)
                    .setPrayerEnabled(prayerName: prayerName, enabled: value);
                if (!context.mounted || granted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Bildirim izni verilmedi. Tercih kapalı kaldı.',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PrayerName prayerName) {
    return switch (prayerName) {
      PrayerName.imsak => Icons.wb_twilight_outlined,
      PrayerName.sunrise => Icons.wb_sunny_outlined,
      PrayerName.dhuhr => Icons.wb_sunny_outlined,
      PrayerName.asr => Icons.wb_twilight_outlined,
      PrayerName.maghrib => Icons.wb_twilight_outlined,
      PrayerName.isha => Icons.nightlight_round,
    };
  }

  Color _colorFor(PrayerName prayerName) {
    return switch (prayerName) {
      PrayerName.imsak => const Color(0xFF216FD6),
      PrayerName.sunrise => const Color(0xFFE4B02F),
      PrayerName.dhuhr => const Color(0xFFE4B02F),
      PrayerName.asr => const Color(0xFF216FD6),
      PrayerName.maghrib => const Color(0xFFE4B02F),
      PrayerName.isha => AppColors.primary,
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      shadow: false,
      color: const Color(0xFFF7FBFF),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konum ve vakitlere göre yenilenir',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Şehir/ilçe veya bildirim tercihi değiştiğinde yakındaki bildirimler yeniden planlanır.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.text,
                    fontSize: 12,
                    height: 1.32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RepaintBoundary(
            child: CustomPaint(
              size: const Size(96, 72),
              painter: _InfoPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEAF3FF),
        border: Border.all(color: Colors.white.withValues(alpha: .82)),
      ),
      child: Icon(icon, color: color, size: 25),
    );
  }
}

class _NotificationBackground extends StatelessWidget {
  const _NotificationBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FBFF), Color(0xFFFFFFFF), Color(0xFFF1F8FF)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _InfoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..color = const Color(0xFF8FBEFF).withValues(alpha: .65);
    final dark = Paint()..color = AppColors.primary.withValues(alpha: .72);
    final soft = Paint()..color = const Color(0xFFD8E9FF);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 12, 58, 48),
        const Radius.circular(9),
      ),
      soft,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 12, 58, 14),
        const Radius.circular(9),
      ),
      blue,
    );
    for (final x in [16.0, 34.0, 52.0]) {
      for (final y in [34.0, 50.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 10, height: 10),
            const Radius.circular(3),
          ),
          Paint()..color = Colors.white.withValues(alpha: .82),
        );
      }
    }
    canvas.drawCircle(Offset(size.width * .74, size.height * .62), 22, blue);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .58, size.height * .42, 34, 34),
        const Radius.circular(18),
      ),
      blue,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .75, size.height * .86),
        width: 30,
        height: 10,
      ),
      dark,
    );
    canvas.drawCircle(Offset(size.width * .75, size.height * .91), 5, dark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _offsetText(int minutes) {
  if (minutes == 60) {
    return '1 saat';
  }
  return '$minutes dakika';
}
