import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../../daily_content/domain/entities/daily_content_metadata.dart';
import '../../../daily_content/presentation/controllers/daily_content_controller.dart';
import '../../../prayer_times/presentation/controllers/prayer_location_controller.dart';
import '../../../prayer_times/domain/entities/current_location_resolution.dart';
import '../../../quran/domain/entities/quran_reading_preferences.dart';
import '../../../quran/presentation/controllers/quran_controller.dart';
import '../../../tasbih/domain/entities/tasbih_preferences.dart';
import '../../../tasbih/presentation/controllers/tasbih_controller.dart';

final appPackageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref
        .watch(selectedPrayerLocationControllerProvider)
        .asData
        ?.value;
    final quranPreferences =
        ref.watch(quranReadingPreferencesControllerProvider).asData?.value ??
        const QuranReadingPreferences();
    final tasbihPreferences =
        ref.watch(tasbihPreferencesControllerProvider).asData?.value ??
        const TasbihPreferences();
    final cacheState = ref.watch(dailyContentCacheControllerProvider);
    final packageInfo = ref.watch(appPackageInfoProvider).asData?.value;

    return AppPage(
      title: 'Ayarlar',
      body: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1,
        child: PremiumScrollView(
          children: [
            Builder(
              builder: (context) => Text(
                'Uygulama tercihlerinizi yönetin.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _AppLogoPanel(),
            _SettingsGroup(
              icon: Icons.location_on_outlined,
              title: 'Konum',
              children: [
                _SettingsActionRow(
                  icon: Icons.location_city_outlined,
                  title: 'Şehir ve İlçe',
                  subtitle: location == null
                      ? 'Namaz vakti konumunu seç'
                      : '${location.city.name} / ${location.district.name}',
                  onTap: () => context.push('/prayer/location'),
                ),
                _SettingsActionRow(
                  icon: Icons.my_location_rounded,
                  title: 'Geçerli Konumu Kullan',
                  subtitle: 'Konum iznini iste ve il/ilçeyi güncelle',
                  onTap: () => _useCurrentLocation(context, ref),
                ),
              ],
            ),
            _SettingsGroup(
              icon: Icons.notifications_none_rounded,
              title: 'Bildirimler',
              children: [
                _SettingsActionRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Namaz Bildirimleri',
                  subtitle: 'Vakitlerden önce hatırlat',
                  onTap: () => context.push('/prayer/notifications'),
                ),
                _SettingsActionRow(
                  icon: Icons.event_available_outlined,
                  title: 'Cuma Hatırlatıcısı',
                  subtitle: 'Her cuma 10:00 hatırlatması',
                  onTap: () => context.push('/friday-reminder'),
                ),
              ],
            ),
            _SettingsGroup(
              icon: Icons.menu_book_outlined,
              title: 'Kur’an Okuma',
              children: [
                _SettingsSwitchRow(
                  icon: Icons.translate_outlined,
                  title: 'Meali Göster',
                  subtitle: 'Türkçe meal satırlarını göster',
                  value: quranPreferences.showTranslation,
                  onChanged: (value) => ref
                      .read(quranReadingPreferencesControllerProvider.notifier)
                      .setShowTranslation(value),
                ),
                _SettingsValueRow(
                  icon: Icons.format_size_outlined,
                  title: 'Arapça Yazı Boyutu',
                  value: quranPreferences.arabicTextSize.round().toString(),
                  onTap: () => _showTextSizeSheet(
                    context: context,
                    title: 'Arapça Yazı Boyutu',
                    value: quranPreferences.arabicTextSize,
                    min: 24,
                    max: 38,
                    divisions: 14,
                    onChanged: (value) => ref
                        .read(
                          quranReadingPreferencesControllerProvider.notifier,
                        )
                        .setArabicTextSize(value),
                  ),
                ),
                _SettingsValueRow(
                  icon: Icons.notes_outlined,
                  title: 'Meal Yazı Boyutu',
                  value: quranPreferences.translationTextSize
                      .round()
                      .toString(),
                  onTap: () => _showTextSizeSheet(
                    context: context,
                    title: 'Meal Yazı Boyutu',
                    value: quranPreferences.translationTextSize,
                    min: 13,
                    max: 22,
                    divisions: 9,
                    onChanged: (value) => ref
                        .read(
                          quranReadingPreferencesControllerProvider.notifier,
                        )
                        .setTranslationTextSize(value),
                  ),
                ),
              ],
            ),
            _SettingsGroup(
              icon: Icons.radio_button_checked_outlined,
              title: 'Tesbih',
              children: [
                _SettingsSwitchRow(
                  icon: Icons.vibration_outlined,
                  title: 'Dokunsal Geri Bildirim',
                  subtitle: 'Her dokunuşta hafif titreşim',
                  value: tasbihPreferences.hapticFeedbackEnabled,
                  onChanged: (value) => ref
                      .read(tasbihPreferencesControllerProvider.notifier)
                      .setHapticFeedbackEnabled(value),
                ),
              ],
            ),
            _SettingsGroup(
              icon: Icons.hexagon_outlined,
              title: 'Diğer',
              children: [
                _ClearDailyContentCacheRow(
                  isBusy: cacheState.isLoading,
                  onTap: cacheState.isLoading
                      ? null
                      : () async {
                          await ref
                              .read(
                                dailyContentCacheControllerProvider.notifier,
                              )
                              .clearCache();
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Günlük içerik önbelleği temizlendi.',
                              ),
                            ),
                          );
                        },
                ),
                _SettingsActionRow(
                  icon: Icons.wallpaper_outlined,
                  title: 'Duvar Kağıtları',
                  subtitle: 'Çevrimdışı premium koleksiyon',
                  onTap: () => context.push('/wallpapers'),
                ),
                _SettingsActionRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Gizlilik Politikası',
                  subtitle: 'Verilerin nasıl kullanıldığını görüntüle',
                  onTap: () => context.push('/settings/privacy'),
                ),
                _SettingsActionRow(
                  icon: Icons.source_outlined,
                  title: 'Kaynaklar ve Lisanslar',
                  subtitle: 'İçerik ve açık kaynak atıfları',
                  onTap: () => context.push('/settings/sources'),
                ),
                _SettingsActionRow(
                  icon: Icons.info_outline_rounded,
                  title: 'Hakkında',
                  subtitle: 'Sürüm ${packageInfo?.version ?? '1.0.5'}',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'İslami Cep',
                    applicationVersion: packageInfo?.version ?? '1.0.5',
                    applicationLegalese: 'Namaz, Kur’an, dua ve günlük içerik.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Konumunuz ve il/ilçe bilginiz belirleniyor...'),
        duration: Duration(seconds: 20),
      ),
    );
    final resolution = await ref
        .read(selectedPrayerLocationControllerProvider.notifier)
        .useCurrentLocation();
    if (!context.mounted) {
      return;
    }
    messenger.hideCurrentSnackBar();
    final location = resolution.location;
    switch (resolution.status) {
      case CurrentLocationResolutionStatus.resolved:
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              location == null
                  ? 'Konum bulundu ancak il/ilçe eşleştirilemedi.'
                  : '${location.city.name} / ${location.district.name} seçildi.',
            ),
          ),
        );
      case CurrentLocationResolutionStatus.permissionDenied:
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Konum izni verilmedi. Tekrar dokunarak izin isteyebilirsiniz.',
            ),
          ),
        );
      case CurrentLocationResolutionStatus.permissionPermanentlyDenied:
        await _showLocationSettingsDialog(
          context,
          title: 'Konum izni kapalı',
          message:
              'iPhone Ayarları’nda İslami Cep için Konum iznini “Uygulamayı Kullanırken” olarak açın.',
          onOpen: Geolocator.openAppSettings,
        );
      case CurrentLocationResolutionStatus.serviceDisabled:
        await _showLocationSettingsDialog(
          context,
          title: 'Konum servisleri kapalı',
          message: 'Konumu kullanmak için iPhone Konum Servislerini açın.',
          onOpen: Geolocator.openLocationSettings,
        );
      case CurrentLocationResolutionStatus.unresolved:
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Konum belirlenemedi. Şehir ve ilçeyi elle seçebilirsiniz.',
            ),
          ),
        );
    }
  }

  Future<void> _showLocationSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() onOpen,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await onOpen();
            },
            child: const Text('Ayarları Aç'),
          ),
        ],
      ),
    );
  }

  void _showTextSizeSheet({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TextSizeSheet(
        title: title,
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

class _AppLogoPanel extends StatelessWidget {
  const _AppLogoPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassPanel(
        borderRadius: 30,
        padding: EdgeInsets.zero,
        shadow: false,
        child: SizedBox(
          height: 104,
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
                          Color(0xFFFFFFFF),
                          Color(0xFFEAF6FF),
                          Color(0xFFDDEFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _SettingsHeroPainter()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/app/logo.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İslami Cep',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Namaz, Kur’an, dua ve günlük içerik ile hayatınıza rehberlik eder.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, color: AppColors.ink, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          GlassPanel(
            borderRadius: 26,
            padding: EdgeInsets.zero,
            shadow: false,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Divider(
                      height: 1,
                      indent: 58,
                      color: AppColors.primary.withValues(alpha: .08),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyContentStatusRow extends StatelessWidget {
  const DailyContentStatusRow({required this.metadata, super.key});

  final AsyncValue<DailyContentMetadata> metadata;

  @override
  Widget build(BuildContext context) {
    final subtitle = metadata.when(
      data: (value) => value.lastSyncAt == null
          ? 'Yerel içerik hazır'
          : 'Son güncelleme: ${_formatDate(value.lastSyncAt!)}',
      loading: () => 'Güncelleme bilgisi yükleniyor',
      error: (_, _) => 'Güncelleme bilgisi okunamadı',
    );

    return _SettingsActionRow(
      icon: Icons.cloud_done_outlined,
      title: 'Günlük İçerik',
      subtitle: subtitle,
      onTap: () {},
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year} $hour:$minute';
  }
}

class _ClearDailyContentCacheRow extends StatelessWidget {
  const _ClearDailyContentCacheRow({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsActionRow(
      icon: Icons.cleaning_services_outlined,
      title: 'Önbelleği Temizle',
      subtitle: isBusy ? 'Temizleniyor...' : 'Uygulama verilerini temizle',
      onTap: onTap,
      trailing: isBusy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _SettingsValueRow extends StatelessWidget {
  const _SettingsValueRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsActionRow(
      icon: icon,
      title: title,
      subtitle: 'Değeri düzenle',
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _TextSizeSheet extends StatefulWidget {
  const _TextSizeSheet({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  State<_TextSizeSheet> createState() => _TextSizeSheetState();
}

class _TextSizeSheetState extends State<_TextSizeSheet> {
  late double value = widget.value;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GlassPanel(
          borderRadius: 28,
          padding: const EdgeInsets.all(18),
          shadow: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: value.clamp(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                label: value.round().toString(),
                onChanged: (next) {
                  setState(() => value = next);
                  widget.onChanged(next);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF8EC4FF).withValues(alpha: .22);
    final white = Paint()..color = Colors.white.withValues(alpha: .58);
    canvas.drawCircle(Offset(size.width * .78, size.height * .48), 34, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .68, size.height * .55, 100, 40),
        const Radius.circular(14),
      ),
      white,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width * .67, size.height * .23, 112, 74),
      3.14,
      3.14,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: .74)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawCircle(Offset(size.width * .72, size.height * .27), 14, white);
    canvas.drawCircle(
      Offset(size.width * .75, size.height * .25),
      14,
      Paint()..color = const Color(0xFFEAF6FF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
