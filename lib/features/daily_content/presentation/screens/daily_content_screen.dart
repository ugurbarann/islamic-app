import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/app_feature_icon.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../quran/presentation/controllers/quran_controller.dart';
import '../../domain/entities/daily_content_item.dart';
import '../../domain/entities/daily_content_type.dart';
import '../controllers/daily_content_controller.dart';

class DailyContentScreen extends ConsumerWidget {
  const DailyContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(todayDailyContentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      body: Stack(
        children: [
          const _DailyBackground(),
          SafeArea(
            bottom: false,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1,
              child: contentAsync.when(
                data: (bundle) => _DailyContentBody(bundle: bundle),
                loading: () =>
                    const LoadingState(title: 'Günün içeriği yükleniyor'),
                error: (error, stackTrace) => ErrorState(
                  title: 'Günün içeriği yüklenemedi',
                  message: error.toString(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyContentBody extends ConsumerWidget {
  const _DailyContentBody({required this.bundle});

  final dynamic bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayah = bundle.ayah as DailyContentItem?;
    final hadith = bundle.hadith as DailyContentItem?;
    final dua = bundle.dua as DailyContentItem?;
    final knowledge = bundle.knowledge as DailyContentItem?;
    final surah = bundle.surahHighlight as DailyContentItem?;
    final lastRead = ref.watch(lastReadControllerProvider).asData?.value;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 138),
          sliver: SliverList.list(
            children: [
              const _DailyHeader(),
              const SizedBox(height: 10),
              ayah == null
                  ? const _DailyFallbackCard(
                      title: 'Günün Ayeti',
                      message: 'Bugünün ayeti henüz hazır değil.',
                      icon: Icons.menu_book_rounded,
                    )
                  : _HeroAyahCard(item: ayah),
              const SizedBox(height: 10),
              _MiniCardsRow(hadith: hadith, dua: dua, knowledge: knowledge),
              const SizedBox(height: 10),
              surah == null
                  ? const _DailyFallbackCard(
                      title: 'Günün Suresi',
                      message: 'Bugünün sure önerisi henüz hazır değil.',
                      icon: Icons.auto_stories_rounded,
                    )
                  : _SurahHighlightCard(item: surah),
              const SizedBox(height: 4),
              _ContinueReadingCard(lastRead: lastRead),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyHeader extends StatelessWidget {
  const _DailyHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bugün',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bugünün ayeti, hadisi, duası ve kısa bilgisi.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _RoundDailyIconButton(
          icon: Icons.calendar_month_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bugünün içerikleri gösteriliyor.')),
            );
          },
        ),
      ],
    );
  }
}

class _HeroAyahCard extends StatelessWidget {
  const _HeroAyahCard({required this.item});

  final DailyContentItem item;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 30,
      padding: EdgeInsets.zero,
      shadow: false,
      onTap: () => _openDailyItem(context, item),
      child: SizedBox(
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF8FCFF),
                        Color(0xFFEAF6FF),
                        Color(0xFFCFEAFF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _HeroMosquePainter()),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.78),
                        Colors.white.withValues(alpha: 0.42),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppFeatureIcon(
                          kind: AppFeatureIconKind.quran,
                          size: 34,
                          iconSize: 23,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Günün Ayeti',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.reference ?? 'Günün Ayeti',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Text(
                          item.arabicText ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.arabic(context).copyWith(
                            color: AppColors.ink,
                            fontSize: 18,
                            height: 1.18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: 286,
                      child: Text(
                        item.turkishText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.text,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          height: 1.32,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _PillActionButton(
                      label: 'Detayını Oku',
                      icon: Icons.menu_book_rounded,
                      onPressed: () => _openDailyItem(context, item),
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

class _MiniCardsRow extends StatelessWidget {
  const _MiniCardsRow({
    required this.hadith,
    required this.dua,
    required this.knowledge,
  });

  final DailyContentItem? hadith;
  final DailyContentItem? dua;
  final DailyContentItem? knowledge;

  @override
  Widget build(BuildContext context) {
    final cards = [
      if (hadith != null)
        _MiniDailyCard(
          item: hadith!,
          icon: Icons.menu_book_outlined,
          accent: const Color(0xFF58B88A),
          background: const Color(0xFFF1FBF7),
        ),
      if (dua != null)
        _MiniDailyCard(
          item: dua!,
          icon: Icons.nightlight_round,
          accent: const Color(0xFFDDAE47),
          background: const Color(0xFFFFFAEF),
        ),
      if (knowledge != null)
        _MiniDailyCard(
          item: knowledge!,
          icon: Icons.article_outlined,
          accent: const Color(0xFF8C64DD),
          background: const Color(0xFFF8F3FF),
        ),
    ];

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i != cards.length - 1) const SizedBox(width: 9),
          ],
        ],
      ),
    );
  }
}

class _MiniDailyCard extends StatelessWidget {
  const _MiniDailyCard({
    required this.item,
    required this.icon,
    required this.accent,
    required this.background,
  });

  final DailyContentItem item;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 25,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      shadow: false,
      color: background.withValues(alpha: 0.76),
      onTap: () => _openDailyItem(context, item),
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniIcon(icon: icon, color: accent),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.reference ?? item.source ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                    fontSize: 9.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Text(
                    item.turkishText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.text,
                      fontSize: 9.4,
                      fontWeight: FontWeight.w800,
                      height: 1.22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _CircleArrowButton(
                color: accent,
                onTap: () => _openDailyItem(context, item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: .62),
        border: Border.all(color: Colors.white.withValues(alpha: .82)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _SurahHighlightCard extends StatelessWidget {
  const _SurahHighlightCard({required this.item});

  final DailyContentItem item;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 28,
      padding: EdgeInsets.zero,
      shadow: false,
      onTap: () => _openDailyItem(context, item),
      child: SizedBox(
        height: 104,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFF9FCFF),
                        Color(0xFFEFF7FF),
                        Color(0xFFE7F4FF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 14,
                top: 12,
                bottom: 0,
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: const Size(164, 126),
                    painter: _OpenQuranPainter(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
                child: Row(
                  children: [
                    const AppFeatureIcon(
                      kind: AppFeatureIconKind.quran,
                      size: 36,
                      iconSize: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günün Suresi',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.reference ?? item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.turkishText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.text,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.28,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SmallReadButton(
                      onTap: () => _openDailyItem(context, item),
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

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.lastRead});

  final dynamic lastRead;

  @override
  Widget build(BuildContext context) {
    final hasLastRead = lastRead != null;
    final detail = hasLastRead
        ? '${lastRead!.surahNumber}. Sure ${lastRead!.ayahNumber}. Ayet'
        : 'Henüz kayıtlı ayet yok.';
    final route = hasLastRead
        ? '/quran/surah/${lastRead!.surahNumber}?ayah=${lastRead!.ayahNumber}'
        : '/quran';

    return GlassPanel(
      borderRadius: 26,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      shadow: false,
      color: const Color(0xFFEFFBF6).withValues(alpha: 0.78),
      child: Row(
        children: [
          const AppFeatureIcon(
            kind: AppFeatureIconKind.calendar,
            size: 40,
            iconSize: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kaldığım Yerden Devam Et',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2E8C69),
                    fontSize: 17,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6BC296),
              foregroundColor: Colors.white,
              minimumSize: const Size(118, 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => context.go(route),
            label: const Text('Devam Et'),
            icon: const Icon(Icons.chevron_right_rounded),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }
}

class _DailyFallbackCard extends StatelessWidget {
  const _DailyFallbackCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 26,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      shadow: false,
      child: Row(
        children: [
          AppFeatureIcon(kind: AppFeatureIconKind.calendar, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.primary),
        ],
      ),
    );
  }
}

class DailyContentCard extends StatelessWidget {
  const DailyContentCard({
    required this.item,
    this.expanded = false,
    super.key,
  });

  final DailyContentItem item;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final iconKind = _iconKindFor(item.type);
    return GlassPanel(
      borderRadius: 30,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppFeatureIcon(kind: iconKind, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (item.reference != null || item.source != null) ...[
            const SizedBox(height: 12),
            Text(
              item.reference ?? item.source!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          if (item.arabicText != null) ...[
            const SizedBox(height: 10),
            Text(
              item.arabicText!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTypography.arabic(context),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            item.turkishText,
            maxLines: expanded ? null : 3,
            overflow: expanded ? null : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: AppSecondaryButton(
              label: 'Detayını Oku',
              icon: Icons.chevron_right_rounded,
              onPressed: () => _openDailyItem(context, item),
            ),
          ),
        ],
      ),
    );
  }

  AppFeatureIconKind _iconKindFor(DailyContentType type) {
    return switch (type) {
      DailyContentType.ayah => AppFeatureIconKind.quran,
      DailyContentType.hadith => AppFeatureIconKind.hadith,
      DailyContentType.dua => AppFeatureIconKind.dua,
      DailyContentType.knowledge => AppFeatureIconKind.knowledge,
      DailyContentType.quote => AppFeatureIconKind.calendar,
      DailyContentType.surahHighlight => AppFeatureIconKind.quran,
    };
  }
}

void _openDailyItem(BuildContext context, DailyContentItem item) {
  final route = item.actionRoute;
  if (route != null && route != '/daily') {
    context.go(route);
    return;
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DailyItemDetailSheet(item: item),
  );
}

class _DailyItemDetailSheet extends StatelessWidget {
  const _DailyItemDetailSheet({required this.item});

  final DailyContentItem item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GlassPanel(
          borderRadius: 30,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          shadow: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .72,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AppFeatureIcon(
                        kind: _detailIconFor(item.type),
                        size: 44,
                        iconSize: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                  if (item.reference != null || item.source != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      item.reference ?? item.source!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  if (item.arabicText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      item.arabicText!,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.arabic(
                        context,
                      ).copyWith(fontSize: 25, height: 1.55),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    item.turkishText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      height: 1.48,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppFeatureIconKind _detailIconFor(DailyContentType type) {
    return switch (type) {
      DailyContentType.ayah => AppFeatureIconKind.quran,
      DailyContentType.hadith => AppFeatureIconKind.hadith,
      DailyContentType.dua => AppFeatureIconKind.dua,
      DailyContentType.knowledge => AppFeatureIconKind.knowledge,
      DailyContentType.quote => AppFeatureIconKind.calendar,
      DailyContentType.surahHighlight => AppFeatureIconKind.quran,
    };
  }
}

class _RoundDailyIconButton extends StatelessWidget {
  const _RoundDailyIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.88),
        boxShadow: AppShadows.soft,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: AppColors.primary,
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        foregroundColor: AppColors.primary,
        elevation: 0,
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _SmallReadButton extends StatelessWidget {
  const _SmallReadButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.88),
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      ),
      onPressed: onTap,
      label: const Text('Oku'),
      icon: const Icon(Icons.chevron_right_rounded),
      iconAlignment: IconAlignment.end,
    );
  }
}

class _CircleArrowButton extends StatelessWidget {
  const _CircleArrowButton({required this.color, this.onTap});

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.56),
          border: Border.all(color: Colors.white.withValues(alpha: 0.66)),
        ),
        child: Icon(Icons.chevron_right_rounded, color: color),
      ),
    );
  }
}

class _DailyBackground extends StatelessWidget {
  const _DailyBackground();

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

class _HeroMosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFC5E5FF), Color(0x00FFFFFF)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.20), 34, glow);

    final moon = Paint()..color = Colors.white.withValues(alpha: 0.96);
    canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.19), 31, moon);
    final cut = Paint()..color = const Color(0xFFCFEAFF);
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.16), 31, cut);

    final mosquePaint = Paint()..color = Colors.white.withValues(alpha: 0.76);
    final blueShade = Paint()
      ..color = const Color(0xFF9CCBFF).withValues(alpha: 0.28);

    final baseY = size.height * 0.78;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.56, baseY - 72, size.width * 0.36, 72),
        const Radius.circular(12),
      ),
      mosquePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.74, baseY - 72),
        width: size.width * 0.30,
        height: 135,
      ),
      3.14,
      3.14,
      false,
      mosquePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.74, baseY - 72),
        width: size.width * 0.30,
        height: 135,
      ),
      3.14,
      3.14,
      false,
      blueShade
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );

    for (final x in [0.61, 0.72, 0.83]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * x, baseY - 42, 18, 42),
          const Radius.circular(9),
        ),
        Paint()..color = const Color(0xFFB7D9FF).withValues(alpha: 0.32),
      );
    }

    for (final x in [0.52, 0.92]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * x, baseY - 150, 16, 150),
          const Radius.circular(8),
        ),
        mosquePaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.width * x - 4, baseY - 150)
          ..lineTo(size.width * x + 8, baseY - 184)
          ..lineTo(size.width * x + 20, baseY - 150)
          ..close(),
        mosquePaint,
      );
      canvas.drawCircle(
        Offset(size.width * x + 8, baseY - 187),
        3,
        mosquePaint,
      );
    }

    final plant = Paint()
      ..color = const Color(0xFF7EADEB).withValues(alpha: 0.20)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final start = Offset(size.width * 0.55, size.height * 0.87);
    canvas.drawLine(
      start,
      Offset(size.width * 0.62, size.height * 0.66),
      plant,
    );
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.82 - i * 0.04);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.58 + i * 0.015), y),
          width: 22,
          height: 10,
        ),
        Paint()..color = const Color(0xFF9EC6F2).withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OpenQuranPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9EC6F2).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF7FB1EA).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final left = Path()
      ..moveTo(size.width * 0.12, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.35,
        size.width * 0.50,
        size.height * 0.58,
      )
      ..lineTo(size.width * 0.50, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.66,
        size.width * 0.12,
        size.height * 0.78,
      )
      ..close();
    final right = Path()
      ..moveTo(size.width * 0.88, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.35,
        size.width * 0.50,
        size.height * 0.58,
      )
      ..lineTo(size.width * 0.50, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.66,
        size.width * 0.88,
        size.height * 0.78,
      )
      ..close();
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
    canvas.drawPath(left, stroke);
    canvas.drawPath(right, stroke);
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.58),
      Offset(size.width * 0.50, size.height * 0.85),
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.28),
      18,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
