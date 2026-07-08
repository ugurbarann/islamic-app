import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_feature_icon.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../controllers/quran_controller.dart';

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);
    final lastReadAsync = ref.watch(lastReadControllerProvider);
    final bookmarks = ref.watch(quranBookmarksControllerProvider).asData?.value;

    return PremiumScaffold(
      title: 'Kur\'an',
      actions: [
        IconButton(
          tooltip: 'Ayet Ara',
          onPressed: () => context.push('/quran/search'),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: 'Yer İşaretleri',
          onPressed: () => context.push('/quran/bookmarks'),
          icon: const Icon(Icons.bookmark_border_rounded),
        ),
      ],
      body: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              sliver: SliverToBoxAdapter(
                child: lastReadAsync.when(
                  data: (ayah) => _QuranHeroCard(ayah: ayah),
                  loading: () => const _QuranHeroCard(ayah: null),
                  error: (_, _) => const _QuranHeroCard(ayah: null),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              sliver: SliverToBoxAdapter(
                child: _QuranStatsRow(bookmarkCount: bookmarks?.length ?? 0),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              sliver: SliverToBoxAdapter(
                child: _QuranSectionBar(
                  onSearch: () => context.push('/quran/search'),
                  onBookmarks: () => context.push('/quran/bookmarks'),
                ),
              ),
            ),
            surahsAsync.when(
              data: (surahs) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                sliver: SliverGrid.builder(
                  itemCount: surahs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.72,
                  ),
                  itemBuilder: (context, index) {
                    final surah = surahs[index];
                    return _SurahGridTile(
                      surah: surah,
                      onTap: () => context.push('/quran/surah/${surah.number}'),
                    );
                  },
                ),
              ),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: PremiumStateView(
                  title: 'Sureler yükleniyor',
                  loading: true,
                ),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: PremiumStateView(
                  title: 'Sureler yüklenemedi',
                  message: error.toString(),
                  icon: Icons.error_outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuranHeroCard extends StatelessWidget {
  const _QuranHeroCard({required this.ayah});

  final Ayah? ayah;

  @override
  Widget build(BuildContext context) {
    final hasLastRead = ayah != null;
    final title = hasLastRead ? '${ayah!.surahNumber}. Sure' : 'Son Okunan';
    final detail = hasLastRead
        ? '${ayah!.surahNumber}:${ayah!.ayahNumber}'
        : 'Henüz kayıtlı ayet yok';

    return GlassPanel(
      borderRadius: 30,
      padding: EdgeInsets.zero,
      shadow: false,
      child: SizedBox(
        height: 190,
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
                        Color(0xFFD8EEFF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _QuranHeroPainter()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppFeatureIcon(
                          kind: AppFeatureIconKind.quran,
                          size: 34,
                          iconSize: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Son Okunan',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                            height: 1.04,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: hasLastRead
                          ? () => context.push(
                              '/quran/surah/${ayah!.surahNumber}?ayah=${ayah!.ayahNumber}',
                            )
                          : () => context.push('/quran/surah/1'),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Devam Et'),
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

class _QuranStatsRow extends StatelessWidget {
  const _QuranStatsRow({required this.bookmarkCount});

  final int bookmarkCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuranStatCard(
            icon: AppFeatureIconKind.quran,
            title: 'Sureler',
            value: '114 sure',
            onTap: null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuranStatCard(
            icon: AppFeatureIconKind.knowledge,
            title: 'Ayetler',
            value: '6.236 ayet',
            onTap: null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuranStatCard(
            icon: AppFeatureIconKind.esma,
            title: 'Cüzler',
            value: '30 cüz',
            onTap: null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuranStatCard(
            icon: AppFeatureIconKind.hadith,
            title: 'Favoriler',
            value: '$bookmarkCount kayıt',
            onTap: () => context.push('/quran/bookmarks'),
          ),
        ),
      ],
    );
  }
}

class _QuranStatCard extends StatelessWidget {
  const _QuranStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final AppFeatureIconKind icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      shadow: false,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFeatureIcon(kind: icon, size: 34, iconSize: 22),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranSectionBar extends StatelessWidget {
  const _QuranSectionBar({required this.onSearch, required this.onBookmarks});

  final VoidCallback onSearch;
  final VoidCallback onBookmarks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            'Sureler',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(onPressed: onBookmarks, child: const Text('Yer İşaretleri')),
        const Spacer(),
        _RoundQuranButton(icon: Icons.search_rounded, onTap: onSearch),
      ],
    );
  }
}

class _RoundQuranButton extends StatelessWidget {
  const _RoundQuranButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.78),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _SurahGridTile extends StatelessWidget {
  const _SurahGridTile({required this.surah, required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      shadow: false,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
            child: Text(
              '${surah.number}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.nameTurkish,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  surah.nameArabic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.arabic(context).copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${surah.ayahCount} ayet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

class _QuranHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..color = const Color(0xFF9BCBFF).withValues(alpha: .22);
    final white = Paint()..color = Colors.white.withValues(alpha: .65);
    final stroke = Paint()
      ..color = const Color(0xFF74AEEF).withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(size.width * .78, size.height * .35), 58, blue);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .58, size.height * .53, 170, 70),
        const Radius.circular(20),
      ),
      white,
    );

    final bookLeft = Path()
      ..moveTo(size.width * .60, size.height * .64)
      ..quadraticBezierTo(
        size.width * .70,
        size.height * .55,
        size.width * .80,
        size.height * .67,
      )
      ..lineTo(size.width * .80, size.height * .86)
      ..quadraticBezierTo(
        size.width * .69,
        size.height * .76,
        size.width * .60,
        size.height * .84,
      )
      ..close();
    final bookRight = Path()
      ..moveTo(size.width * .80, size.height * .67)
      ..quadraticBezierTo(
        size.width * .90,
        size.height * .55,
        size.width * .98,
        size.height * .64,
      )
      ..lineTo(size.width * .98, size.height * .84)
      ..quadraticBezierTo(
        size.width * .89,
        size.height * .76,
        size.width * .80,
        size.height * .86,
      )
      ..close();
    canvas.drawPath(bookLeft, white);
    canvas.drawPath(bookRight, white);
    canvas.drawPath(bookLeft, stroke);
    canvas.drawPath(bookRight, stroke);

    final dome = Rect.fromLTWH(size.width * .70, size.height * .28, 92, 82);
    canvas.drawArc(dome, 3.14, 3.14, false, stroke);
    canvas.drawLine(
      Offset(size.width * .70, size.height * .69),
      Offset(size.width * .95, size.height * .69),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
