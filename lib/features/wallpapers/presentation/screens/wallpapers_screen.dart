import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/entities/wallpaper_category.dart';
import '../controllers/wallpaper_controller.dart';
import '../widgets/wallpaper_preview.dart';

class WallpapersScreen extends ConsumerStatefulWidget {
  const WallpapersScreen({super.key});

  @override
  ConsumerState<WallpapersScreen> createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends ConsumerState<WallpapersScreen> {
  final _random = Random();
  String? _selectedCategoryId = 'recommended';
  String? _heroWallpaperId;

  @override
  Widget build(BuildContext context) {
    final wallpapersAsync = ref.watch(wallpapersProvider);
    final categoriesAsync = ref.watch(wallpaperCategoriesProvider);
    final favoritesAsync = ref.watch(favoriteWallpapersControllerProvider);
    final actionAsync = ref.watch(wallpaperDeviceActionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          bottom: false,
          child: wallpapersAsync.when(
            data: (wallpapers) {
              final categories =
                  categoriesAsync.asData?.value ?? const <WallpaperCategory>[];
              final favoriteIds =
                  favoritesAsync.asData?.value ?? const <String>[];
              final visibleWallpapers =
                  _selectedCategoryId == null ||
                      _selectedCategoryId == 'recommended'
                  ? wallpapers
                  : wallpapers
                        .where((item) => item.categoryId == _selectedCategoryId)
                        .toList(growable: false);
              final heroWallpaper = _resolveHeroWallpaper(wallpapers);

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 142),
                children: [
                  _Header(
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/explore');
                      }
                    },
                    onFilter: () => _showFilterSheet(categories),
                  ),
                  const SizedBox(height: 8),
                  _HeroWallpaperCard(
                    wallpaper: heroWallpaper,
                    onExplore: () =>
                        _showRandomHeroWallpaper(wallpapers, heroWallpaper),
                  ),
                  const SizedBox(height: 16),
                  _CategoryStrip(
                    categories: categories,
                    selectedCategoryId: _selectedCategoryId,
                    onSelected: (categoryId) {
                      setState(() => _selectedCategoryId = categoryId);
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    onShowAll: () => _openAllWallpapers(wallpapers),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 168,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: visibleWallpapers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final wallpaper = visibleWallpapers[index];
                        return _WallpaperTile(
                          wallpaper: wallpaper,
                          isFavorite: favoriteIds.contains(wallpaper.id),
                          isWorking: actionAsync.isLoading,
                          onOpen: () =>
                              context.push('/wallpapers/${wallpaper.id}'),
                          onFavorite: () => ref
                              .read(
                                favoriteWallpapersControllerProvider.notifier,
                              )
                              .toggleFavorite(wallpaper.id),
                          onDownload: () => _download(wallpaper),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                _ErrorState(message: error.toString()),
          ),
        ),
      ),
    );
  }

  Wallpaper _resolveHeroWallpaper(List<Wallpaper> wallpapers) {
    if (_heroWallpaperId != null) {
      for (final wallpaper in wallpapers) {
        if (wallpaper.id == _heroWallpaperId) {
          return wallpaper;
        }
      }
    }

    return wallpapers.firstWhere(
      (item) => item.id == 'wp_serene_white_mosque',
      orElse: () => wallpapers.firstWhere(
        (item) => item.categoryId == 'recommended',
        orElse: () => wallpapers.first,
      ),
    );
  }

  void _showRandomHeroWallpaper(
    List<Wallpaper> wallpapers,
    Wallpaper currentWallpaper,
  ) {
    if (wallpapers.length < 2) {
      return;
    }

    final candidates = wallpapers
        .where((wallpaper) => wallpaper.id != currentWallpaper.id)
        .toList(growable: false);
    final nextWallpaper = candidates[_random.nextInt(candidates.length)];
    setState(() => _heroWallpaperId = nextWallpaper.id);
  }

  void _openAllWallpapers(List<Wallpaper> wallpapers) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AllWallpapersScreen(wallpapers: wallpapers),
      ),
    );
  }

  Future<void> _download(Wallpaper wallpaper) async {
    final result = await ref
        .read(wallpaperDeviceActionControllerProvider.notifier)
        .download(wallpaper);
    if (!mounted) {
      return;
    }
    _showSnack(result.message);
  }

  void _showFilterSheet(List<WallpaperCategory> categories) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .62,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kategori Seç',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _FilterTile(
                    icon: Icons.apps_rounded,
                    title: 'Tümü',
                    selected: _selectedCategoryId == null,
                    onTap: () {
                      setState(() => _selectedCategoryId = null);
                      Navigator.pop(context);
                    },
                  ),
                  for (final category in categories)
                    _FilterTile(
                      icon: _categoryIcon(category.id),
                      title: category.title,
                      selected: _selectedCategoryId == category.id,
                      onTap: () {
                        setState(() => _selectedCategoryId = category.id);
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onFilter});

  final VoidCallback onBack;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 6,
            child: SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                tooltip: 'Geri',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 28),
                color: AppColors.ink,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          Positioned(
            left: 46,
            right: 34,
            top: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duvar Kağıtları',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 25,
                    height: 1.04,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ekranınıza huzur katacak İslami duvar kağıtları',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              width: 42,
              height: 42,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .94),
                  boxShadow: AppShadows.soft,
                ),
                child: IconButton(
                  tooltip: 'Filtrele',
                  onPressed: onFilter,
                  icon: const Icon(Icons.tune_rounded),
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroWallpaperCard extends StatelessWidget {
  const _HeroWallpaperCard({required this.wallpaper, required this.onExplore});

  final Wallpaper wallpaper;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            WallpaperPreview(
              wallpaper: wallpaper,
              useThumbnail: false,
              cacheWidth: 860,
              borderRadius: 0,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(alpha: .82),
                    Colors.white.withValues(alpha: .38),
                    Colors.white.withValues(alpha: .04),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 42,
              top: 34,
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: .82),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_border_rounded,
                          color: AppColors.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ÖNERİLEN',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.ink,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Huzur veren\ngörüntüler',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.ink,
                      fontSize: 20.5,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Ruhunuzu dinlendirecek özel seçim duvar kağıtları',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      fontSize: 11.2,
                      fontWeight: FontWeight.w800,
                      height: 1.24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: onExplore,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.shuffle_rounded, size: 16),
                    label: const Text('Keşfet'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF244C9B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      fixedSize: const Size(82, 30),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<WallpaperCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category.id == selectedCategoryId;
          return _CategoryChip(
            title: category.title,
            icon: _categoryIcon(category.id),
            selected: selected,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.primary : AppColors.text;
    return Material(
      color: selected
          ? AppColors.primarySoft
          : Colors.white.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .72)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: foreground),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontSize: 10.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Popüler Duvar Kağıtları',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onShowAll,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_right_rounded),
          label: const Text('Tümünü Gör'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.muted,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _AllWallpapersScreen extends ConsumerWidget {
  const _AllWallpapersScreen({required this.wallpapers});

  final List<Wallpaper> wallpapers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteWallpapersControllerProvider);
    final actionAsync = ref.watch(wallpaperDeviceActionControllerProvider);
    final favoriteIds = favoritesAsync.asData?.value ?? const <String>[];

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 118),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Geri',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 30),
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tüm Duvar Kağıtları',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wallpapers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .62,
                ),
                itemBuilder: (context, index) {
                  final wallpaper = wallpapers[index];
                  return _WallpaperGridCard(
                    wallpaper: wallpaper,
                    isFavorite: favoriteIds.contains(wallpaper.id),
                    isWorking: actionAsync.isLoading,
                    onOpen: () => context.push('/wallpapers/${wallpaper.id}'),
                    onFavorite: () => ref
                        .read(favoriteWallpapersControllerProvider.notifier)
                        .toggleFavorite(wallpaper.id),
                    onDownload: () => _downloadFromGrid(
                      context,
                      ref,
                      wallpaper,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFromGrid(
    BuildContext context,
    WidgetRef ref,
    Wallpaper wallpaper,
  ) async {
    final result = await ref
        .read(wallpaperDeviceActionControllerProvider.notifier)
        .download(wallpaper);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }
}

class _WallpaperTile extends StatelessWidget {
  const _WallpaperTile({
    required this.wallpaper,
    required this.isFavorite,
    required this.isWorking,
    required this.onOpen,
    required this.onFavorite,
    required this.onDownload,
  });

  final Wallpaper wallpaper;
  final bool isFavorite;
  final bool isWorking;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpen,
                child: WallpaperPreview(
                  wallpaper: wallpaper,
                  useThumbnail: true,
                  cacheWidth: 360,
                  borderRadius: 0,
                ),
              ),
            ),
            Positioned(
              right: 9,
              top: 9,
              child: _HeartOverlayButton(
                tooltip: isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onPressed: onFavorite,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: _RoundOverlayButton(
                tooltip: 'Galeriye kaydet',
                icon: Icons.download_rounded,
                onPressed: isWorking ? null : onDownload,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpaperGridCard extends StatelessWidget {
  const _WallpaperGridCard({
    required this.wallpaper,
    required this.isFavorite,
    required this.isWorking,
    required this.onOpen,
    required this.onFavorite,
    required this.onDownload,
  });

  final Wallpaper wallpaper;
  final bool isFavorite;
  final bool isWorking;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onOpen,
              child: WallpaperPreview(
                wallpaper: wallpaper,
                useThumbnail: true,
                cacheWidth: 520,
                borderRadius: 0,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.ink.withValues(alpha: .72),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 34, 10, 10),
                child: Text(
                  wallpaper.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 9,
            top: 9,
            child: _HeartOverlayButton(
              tooltip: isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
              icon: isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              onPressed: onFavorite,
            ),
          ),
          Positioned(
            right: 9,
            bottom: 9,
            child: _RoundOverlayButton(
              tooltip: 'Galeriye kaydet',
              icon: Icons.download_rounded,
              onPressed: isWorking ? null : onDownload,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundOverlayButton extends StatelessWidget {
  const _RoundOverlayButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.white.withValues(alpha: .92),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 18),
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _HeartOverlayButton extends StatelessWidget {
  const _HeartOverlayButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      icon: Icon(
        icon,
        size: 23,
        shadows: [
          Shadow(color: AppColors.ink.withValues(alpha: .35), blurRadius: 6),
        ],
      ),
      color: Colors.white,
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : AppColors.text),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: selected ? AppColors.primary : AppColors.text,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Duvar kağıtları yüklenemedi.\n$message',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

IconData _categoryIcon(String categoryId) {
  return switch (categoryId) {
    'recommended' => Icons.stars_rounded,
    'al_aqsa' => Icons.account_balance_rounded,
    'masjid' => Icons.account_balance_rounded,
    'kaaba' => Icons.crop_square_rounded,
    'nature' => Icons.eco_rounded,
    'calligraphy' => Icons.brush_rounded,
    _ => Icons.wallpaper_rounded,
  };
}
