import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../core/platform/wallpaper_device_service.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../domain/entities/wallpaper.dart';
import '../controllers/wallpaper_controller.dart';
import '../widgets/wallpaper_preview.dart';

class WallpaperDetailScreen extends ConsumerWidget {
  const WallpaperDetailScreen({required this.wallpaperId, super.key});

  final String wallpaperId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaperAsync = ref.watch(wallpaperDetailProvider(wallpaperId));
    final favoritesAsync = ref.watch(favoriteWallpapersControllerProvider);
    final actionAsync = ref.watch(wallpaperDeviceActionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          bottom: false,
          child: wallpaperAsync.when(
            data: (wallpaper) {
              final favoriteIds =
                  favoritesAsync.asData?.value ?? const <String>[];
              final isFavorite = favoriteIds.contains(wallpaper.id);
              final isWorking = actionAsync.isLoading;

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 118),
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Geri',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 30),
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          wallpaper.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: isFavorite
                            ? 'Favoriden çıkar'
                            : 'Favoriye ekle',
                        onPressed: () => ref
                            .read(favoriteWallpapersControllerProvider.notifier)
                            .toggleFavorite(wallpaper.id),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                        color: isFavorite ? Colors.redAccent : AppColors.ink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WallpaperPreview(
                    wallpaper: wallpaper,
                    height: 560,
                    cacheWidth: 1080,
                    borderRadius: 30,
                  ),
                  const SizedBox(height: 18),
                  GlassPanel(
                    borderRadius: 26,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    shadow: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Premium duvar kağıdı',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          Platform.isIOS
                              ? 'Paylaşım ekranından görüntüyü Fotoğraflar’a '
                                    'kaydedebilir, ardından iPhone Ayarları’ndan '
                                    'duvar kağıdı yapabilirsiniz.'
                              : 'Galeriye kaydedebilir, paylaşabilir veya ana '
                                    'ekran duvar kağıdı olarak uygulayabilirsiniz.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: isWorking
                              ? null
                              : () async {
                                  final result = await ref
                                      .read(
                                        wallpaperDeviceActionControllerProvider
                                            .notifier,
                                      )
                                      .download(wallpaper);
                                  if (context.mounted) {
                                    _showResult(context, result.message);
                                  }
                                },
                          icon: Icon(
                            Platform.isIOS
                                ? Icons.ios_share_rounded
                                : Icons.download_rounded,
                          ),
                          label: Text(
                            isWorking
                                ? 'İşleniyor'
                                : Platform.isIOS
                                ? 'Paylaş / Fotoğraflara Kaydet'
                                : 'Galeriye Kaydet',
                          ),
                        ),
                        if (!Platform.isIOS) ...[
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: isWorking
                                ? null
                                : () => _showWallpaperTargetSheet(
                                    context,
                                    ref,
                                    wallpaper,
                                  ),
                            icon: const Icon(Icons.wallpaper_rounded),
                            label: const Text('Duvar Kağıdı Yap'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: isWorking
                                ? null
                                : () async {
                                    final result = await ref
                                        .read(
                                          wallpaperDeviceActionControllerProvider
                                              .notifier,
                                        )
                                        .share(wallpaper);
                                    if (context.mounted) {
                                      _showResult(context, result.message);
                                    }
                                  },
                            icon: const Icon(Icons.ios_share_rounded),
                            label: const Text('Paylaş'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Duvar kağıdı yüklenemedi.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showWallpaperTargetSheet(
    BuildContext context,
    WidgetRef ref,
    Wallpaper wallpaper,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Duvar kağıdı olarak ayarla',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _WallpaperTargetTile(
                  icon: Icons.phone_android_rounded,
                  title: 'Sadece Ana Ekran',
                  onTap: () => _applyWallpaperTarget(
                    sheetContext,
                    ref,
                    wallpaper,
                    WallpaperTarget.home,
                  ),
                ),
                _WallpaperTargetTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Sadece Kilit Ekranı',
                  onTap: () => _applyWallpaperTarget(
                    sheetContext,
                    ref,
                    wallpaper,
                    WallpaperTarget.lock,
                  ),
                ),
                _WallpaperTargetTile(
                  icon: Icons.phonelink_lock_rounded,
                  title: 'Ana Ekran ve Kilit Ekranı',
                  onTap: () => _applyWallpaperTarget(
                    sheetContext,
                    ref,
                    wallpaper,
                    WallpaperTarget.both,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _applyWallpaperTarget(
    BuildContext sheetContext,
    WidgetRef ref,
    Wallpaper wallpaper,
    WallpaperTarget target,
  ) async {
    final messenger = ScaffoldMessenger.of(sheetContext);
    Navigator.of(sheetContext).pop();
    final result = await ref
        .read(wallpaperDeviceActionControllerProvider.notifier)
        .setAsWallpaper(wallpaper, target);
    messenger.showSnackBar(SnackBar(content: Text(result.message)));
  }
}

class _WallpaperTargetTile extends StatelessWidget {
  const _WallpaperTargetTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primarySoft,
        foregroundColor: AppColors.primary,
        child: Icon(icon),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
