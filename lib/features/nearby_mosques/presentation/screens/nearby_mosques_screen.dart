import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_feature_icon.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/mosque_distance.dart';
import '../../domain/entities/nearby_mosque_result.dart';
import '../controllers/nearby_mosque_controller.dart';

class NearbyMosquesScreen extends ConsumerStatefulWidget {
  const NearbyMosquesScreen({super.key});

  @override
  ConsumerState<NearbyMosquesScreen> createState() =>
      _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends ConsumerState<NearbyMosquesScreen>
    with WidgetsBindingObserver {
  static const _limit = 5;
  int _radiusMeters = 5000;
  int _refreshToken = 0;
  bool _showFallbackWarning = true;
  bool _refreshAfterReturningFromSettings = false;

  NearbyMosqueQuery get _query => NearbyMosqueQuery(
    radiusMeters: _radiusMeters,
    limit: _limit,
    refreshToken: _refreshToken,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _refreshAfterReturningFromSettings) {
      _refreshAfterReturningFromSettings = false;
      _refreshNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _query;
    final mosquesAsync = ref.watch(nearbyMosquesProvider(query));

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      body: Stack(
        children: [
          const _MosquePageBackground(),
          SafeArea(
            bottom: false,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1,
              child: mosquesAsync.when(
                data: (result) => _MosqueList(
                  result: result,
                  radiusMeters: _radiusMeters,
                  showFallbackWarning: _showFallbackWarning,
                  onDismissFallbackWarning: () {
                    setState(() => _showFallbackWarning = false);
                  },
                  onRetry: () {
                    _refreshNow();
                  },
                  onRefresh: _refreshNow,
                  onFilter: _showFilterSheet,
                  onOpenLocationSettings: _openLocationSettings,
                ),
                loading: () => const PremiumStateView(
                  title: 'Yakındaki camiler aranıyor',
                  message: 'Konum ve canlı cami listesi kontrol ediliyor.',
                  loading: true,
                ),
                error: (error, stackTrace) => PremiumStateView(
                  title: 'Yakındaki camiler yüklenemedi',
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

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .58,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mesafe filtresi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Canlı aramada seçilen mesafe içinde en yakın $_limit cami listelenir.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final option in _RadiusOption.values)
                    _RadiusTile(
                      option: option,
                      selected: option.meters == _radiusMeters,
                      onTap: () {
                        setState(() {
                          _radiusMeters = option.meters;
                          _showFallbackWarning = true;
                        });
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _refreshNow() {
    setState(() {
      _showFallbackWarning = true;
      _refreshToken++;
    });
  }

  Future<void> _openLocationSettings(
    NearbyMosqueLocationStatus locationStatus,
  ) async {
    _refreshAfterReturningFromSettings = true;
    final opened = locationStatus == NearbyMosqueLocationStatus.serviceDisabled
        ? await Geolocator.openLocationSettings()
        : await Geolocator.openAppSettings();
    if (!opened) {
      _refreshAfterReturningFromSettings = false;
    }
  }
}

class _MosqueList extends StatelessWidget {
  const _MosqueList({
    required this.result,
    required this.radiusMeters,
    required this.showFallbackWarning,
    required this.onDismissFallbackWarning,
    required this.onRetry,
    required this.onRefresh,
    required this.onFilter,
    required this.onOpenLocationSettings,
  });

  final NearbyMosqueResult result;
  final int radiusMeters;
  final bool showFallbackWarning;
  final VoidCallback onDismissFallbackWarning;
  final VoidCallback onRetry;
  final VoidCallback onRefresh;
  final VoidCallback onFilter;
  final void Function(NearbyMosqueLocationStatus) onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final mosques = result.mosques.take(5).toList();
    if (mosques.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 120),
        children: [
          const PremiumStateView(
            title: 'Yakınlarda cami bulunamadı',
            message: 'Konumunuzu veya seçili şehir bilgisini kontrol edin.',
            icon: Icons.mosque_outlined,
          ),
          if (_requiresLocationSettings)
            _LocationAccessBanner(
              status: result.locationStatus,
              onOpenSettings: onOpenLocationSettings,
            ),
        ],
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 220),
      children: [
        _MosqueHeader(onFilter: onFilter),
        const SizedBox(height: 8),
        if (_requiresLocationSettings)
          _LocationAccessBanner(
            status: result.locationStatus,
            onOpenSettings: onOpenLocationSettings,
          ),
        if (_requiresLocationSettings) const SizedBox(height: 8),
        if (result.usedFallback)
          _RetryBanner(radiusMeters: radiusMeters, onRetry: onRetry),
        if (result.usedFallback) const SizedBox(height: 8),
        if (!result.usedFallback || showFallbackWarning)
          _RefreshBanner(
            text: result.message != null
                ? result.message!
                : 'Canlı cami araması hazır. Güncel sonuçlar gösteriliyor.',
            warning: result.usedFallback,
            onClose: result.usedFallback ? onDismissFallbackWarning : null,
            onRefresh: onRefresh,
            nextRefreshAllowedAt: result.nextRefreshAllowedAt,
          ),
        const SizedBox(height: 10),
        for (final mosqueDistance in mosques)
          _MosqueCard(mosqueDistance: mosqueDistance),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse('https://www.openstreetmap.org/copyright'),
            mode: LaunchMode.externalApplication,
          ),
          child: const Text(
            'Cami verileri: Google Maps Platform ve © OpenStreetMap katkıcıları',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  bool get _requiresLocationSettings =>
      result.locationStatus == NearbyMosqueLocationStatus.permissionDenied ||
      result.locationStatus == NearbyMosqueLocationStatus.serviceDisabled;
}

class _MosqueHeader extends StatelessWidget {
  const _MosqueHeader({required this.onFilter});

  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return SizedBox(
      height: 132,
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _MosqueHeaderPainter()),
            ),
          ),
          Positioned(
            right: 4,
            top: 34,
            child: _HeaderCircleButton(
              icon: Icons.tune_rounded,
              onTap: onFilter,
            ),
          ),
          if (canPop)
            Positioned(
              left: 4,
              top: 4,
              child: _HeaderCircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => context.pop(),
              ),
            ),
          Positioned(
            left: 4,
            right: 76,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yakındaki Camiler',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.04,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Konumunuza en yakın camileri keşfedin.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
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

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .94),
          boxShadow: AppShadows.soft,
        ),
        child: IconButton(
          tooltip: 'Filtrele',
          onPressed: onTap,
          icon: Icon(icon),
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _RetryBanner extends StatelessWidget {
  const _RetryBanner({required this.radiusMeters, required this.onRetry});

  final int radiusMeters;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      shadow: false,
      color: Colors.white.withValues(alpha: .86),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Canlı cami listesi alınamadı.\n${_formatRadius(radiusMeters)} içinde tekrar ara.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              minimumSize: const Size(88, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}

class _LocationAccessBanner extends StatelessWidget {
  const _LocationAccessBanner({
    required this.status,
    required this.onOpenSettings,
  });

  final NearbyMosqueLocationStatus status;
  final void Function(NearbyMosqueLocationStatus) onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final serviceDisabled =
        status == NearbyMosqueLocationStatus.serviceDisabled;
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.all(14),
      shadow: false,
      color: const Color(0xFFFFF8E7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                serviceDisabled
                    ? Icons.location_off_outlined
                    : Icons.location_searching_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  serviceDisabled
                      ? 'Yakınınızdaki camileri gösterebilmek için iPhone Konum Servislerini açın.'
                      : 'Yakınınızdaki camileri gösterebilmek için Ayarlar’dan İslami Cep konum iznini “Uygulamayı Kullanırken” olarak açın.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => onOpenSettings(status),
            icon: const Icon(Icons.settings_outlined),
            label: Text(
              serviceDisabled
                  ? 'Konum Servislerini Aç'
                  : 'Ayarlar’dan Konum İzni Ver',
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshBanner extends StatelessWidget {
  const _RefreshBanner({
    required this.text,
    required this.onRefresh,
    this.nextRefreshAllowedAt,
    this.warning = false,
    this.onClose,
  });

  final String text;
  final bool warning;
  final VoidCallback? onClose;
  final VoidCallback onRefresh;
  final DateTime? nextRefreshAllowedAt;

  @override
  Widget build(BuildContext context) {
    final canRefresh =
        nextRefreshAllowedAt == null ||
        DateTime.now().isAfter(nextRefreshAllowedAt!);
    final displayText = !warning && !canRefresh
        ? 'Yakındaki camiler güncel. Yenilemek için ${_formatRemaining(nextRefreshAllowedAt!.difference(DateTime.now()))} bekleyin.'
        : text;

    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      shadow: false,
      color: warning
          ? const Color(0xFFFFF6E3).withValues(alpha: .88)
          : Colors.white.withValues(alpha: .82),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: warning ? const Color(0xFFFFE9B8) : AppColors.primarySoft,
            ),
            child: Icon(
              warning
                  ? Icons.notifications_off_outlined
                  : Icons.refresh_rounded,
              color: warning ? const Color(0xFFD79A22) : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              displayText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.24,
              ),
            ),
          ),
          if (warning)
            IconButton(
              tooltip: 'Uyarıyı kapat',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFFE4B34E),
            )
          else
            FilledButton.icon(
              onPressed: canRefresh ? onRefresh : null,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Yenile'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(92, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MosqueCard extends StatelessWidget {
  const _MosqueCard({required this.mosqueDistance});

  final MosqueDistance mosqueDistance;

  @override
  Widget build(BuildContext context) {
    final mosque = mosqueDistance.mosque;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        borderRadius: 24,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        shadow: false,
        color: Colors.white.withValues(alpha: .92),
        child: SizedBox(
          height: 88,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppFeatureIcon(
                kind: AppFeatureIconKind.mosque,
                size: 50,
                iconSize: 29,
                color: _cardColor(mosqueDistance),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.14,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.muted,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mosque.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 118,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatDistance(mosqueDistance.distanceMeters),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.bookmark_border_rounded,
                          color: AppColors.muted,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 118,
                      height: 34,
                      child: FilledButton.icon(
                        onPressed: () =>
                            _openDirections(context, mosqueDistance),
                        icon: const Icon(Icons.near_me_outlined, size: 15),
                        label: const Text(
                          'Yol Tarifi Al',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0C56AD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
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
}

enum _RadiusOption {
  one(1000, '1 km'),
  three(3000, '3 km'),
  five(5000, '5 km'),
  ten(10000, '10 km');

  const _RadiusOption(this.meters, this.label);

  final int meters;
  final String label;
}

class _RadiusTile extends StatelessWidget {
  const _RadiusTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _RadiusOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: selected
            ? AppColors.primary
            : AppColors.primarySoft.withValues(alpha: .72),
        foregroundColor: selected ? Colors.white : AppColors.primary,
        child: const Icon(Icons.social_distance_rounded),
      ),
      title: Text(
        option.label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: selected ? AppColors.primary : AppColors.ink,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: const Text('En yakın 5 cami'),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

Color _cardColor(MosqueDistance mosqueDistance) {
  final index = mosqueDistance.mosque.id.hashCode.abs() % 4;
  return switch (index) {
    0 => AppColors.primary,
    1 => const Color(0xFF29B990),
    2 => const Color(0xFF6750D8),
    _ => const Color(0xFFB08A38),
  };
}

String _formatRadius(int meters) {
  if (meters < 1000) {
    return '$meters m';
  }
  return '${(meters / 1000).toStringAsFixed(meters % 1000 == 0 ? 0 : 1)} km';
}

String _formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.round()} m';
  }
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

String _formatRemaining(Duration duration) {
  final minutes = duration.inMinutes + (duration.inSeconds % 60 == 0 ? 0 : 1);
  if (minutes <= 1) {
    return '1 dk';
  }
  return '$minutes dk';
}

Future<void> _openDirections(
  BuildContext context,
  MosqueDistance mosqueDistance,
) async {
  final mosque = mosqueDistance.mosque;
  final destination = '${mosque.latitude},${mosque.longitude}';

  final candidates = <Uri>[
    Uri.parse('google.navigation:q=$destination&mode=d'),
    Uri.parse('geo:0,0?q=$destination(${Uri.encodeComponent(mosque.name)})'),
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
    }),
  ];

  for (final uri in candidates) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } on Object {
      continue;
    }
  }

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Yol tarifi açılamadı.')));
}

class _MosquePageBackground extends StatelessWidget {
  const _MosquePageBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF6FF), Color(0xFFF9FDFF), Color(0xFFEFF8FF)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _MosqueHeaderPainter extends CustomPainter {
  const _MosqueHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FC6FF).withValues(alpha: .18);
    final baseY = size.height * .82;

    canvas.drawCircle(Offset(size.width * .70, baseY - 86), 54, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .56, baseY - 82, size.width * .35, 76),
        const Radius.circular(12),
      ),
      paint,
    );
    for (final x in [size.width * .48, size.width * .93]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, baseY - 138, 18, 138),
          const Radius.circular(9),
        ),
        paint,
      );
      final path = Path()
        ..moveTo(x - 5, baseY - 138)
        ..lineTo(x + 9, baseY - 166)
        ..lineTo(x + 23, baseY - 138)
        ..close();
      canvas.drawPath(path, paint);
    }
    final crescent = Paint()
      ..color = const Color(0xFF7DB8F6).withValues(alpha: .18);
    canvas.drawCircle(Offset(size.width * .63, baseY - 132), 17, crescent);
    canvas.drawCircle(
      Offset(size.width * .67, baseY - 136),
      17,
      Paint()..color = const Color(0xFFEAF6FF).withValues(alpha: .78),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
