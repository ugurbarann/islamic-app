import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_components.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/quran_reading_preferences.dart';
import '../../domain/entities/surah.dart';
import '../controllers/quran_controller.dart';

class SurahDetailScreen extends ConsumerWidget {
  const SurahDetailScreen({
    required this.surahNumber,
    this.initialAyahNumber,
    super.key,
  });

  final int surahNumber;
  final int? initialAyahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahProvider(surahNumber));
    final ayahsAsync = ref.watch(surahAyahsProvider(surahNumber));

    return PremiumScaffold(
      title: '$surahNumber. Sure',
      body: surahAsync.when(
        data: (surah) => ayahsAsync.when(
          data: (ayahs) => _SurahReadingPage(
            surah: surah,
            ayahs: ayahs,
            initialAyahNumber: initialAyahNumber,
          ),
          loading: () => const LoadingState(title: 'Sure yükleniyor'),
          error: (error, stackTrace) =>
              ErrorState(title: 'Sure yüklenemedi', message: error.toString()),
        ),
        loading: () => const LoadingState(title: 'Sure yükleniyor'),
        error: (error, stackTrace) =>
            ErrorState(title: 'Sure yüklenemedi', message: error.toString()),
      ),
    );
  }
}

class _SurahReadingPage extends ConsumerStatefulWidget {
  const _SurahReadingPage({
    required this.surah,
    required this.ayahs,
    required this.initialAyahNumber,
  });

  final Surah surah;
  final List<Ayah> ayahs;
  final int? initialAyahNumber;

  @override
  ConsumerState<_SurahReadingPage> createState() => _SurahReadingPageState();
}

class _SurahReadingPageState extends ConsumerState<_SurahReadingPage> {
  late final ScrollController _scrollController;

  static const _headerExtentEstimate = 210.0;
  static const _ayahExtentEstimate = 270.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _offsetForAyah(widget.initialAyahNumber),
    );
  }

  @override
  void didUpdateWidget(covariant _SurahReadingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAyahNumber != oldWidget.initialAyahNumber &&
        widget.initialAyahNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) {
          return;
        }
        _scrollController.jumpTo(_offsetForAyah(widget.initialAyahNumber));
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          sliver: SliverToBoxAdapter(
            child: GlassPanel(
              borderRadius: 32,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                children: [
                  _SurahHeader(surah: widget.surah),
                  _SurahLastReadAction(
                    surahNumber: widget.surah.number,
                    onContinue: _scrollToAyah,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
          sliver: SliverList.builder(
            itemCount: widget.ayahs.length,
            itemBuilder: (context, index) {
              return _ContinuousAyahRow(
                ayah: widget.ayahs[index],
                isFirst: index == 0,
                isLast: index == widget.ayahs.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  double _offsetForAyah(int? ayahNumber) {
    if (ayahNumber == null || ayahNumber <= 1) {
      return 0;
    }
    return _headerExtentEstimate + (ayahNumber - 1) * _ayahExtentEstimate;
  }

  void _scrollToAyah(int ayahNumber) {
    if (!_scrollController.hasClients) {
      return;
    }
    final maxExtent = _scrollController.position.maxScrollExtent;
    final target = math.min(_offsetForAyah(ayahNumber), maxExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _SurahLastReadAction extends ConsumerWidget {
  const _SurahLastReadAction({
    required this.surahNumber,
    required this.onContinue,
  });

  final int surahNumber;
  final ValueChanged<int> onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadAyah = ref.watch(lastReadControllerProvider).asData?.value;
    if (lastReadAyah == null || lastReadAyah.surahNumber != surahNumber) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _ContinueReadingChip(
        label: 'Kaldığım Yerden Devam Et',
        detail: '${lastReadAyah.surahNumber}:${lastReadAyah.ayahNumber}',
        onPressed: () => onContinue(lastReadAyah.ayahNumber),
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          surah.nameArabic,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: AppTypography.arabic(
            context,
          ).copyWith(fontSize: 38, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          surah.nameTurkish,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(label: '${surah.number}. Sure'),
            _MetaChip(label: '${surah.ayahCount} Ayet'),
            if (surah.revelationType != null)
              _MetaChip(label: surah.revelationType!),
          ],
        ),
      ],
    );
  }
}

class _ContinueReadingChip extends StatelessWidget {
  const _ContinueReadingChip({
    required this.label,
    required this.detail,
    required this.onPressed,
  });

  final String label;
  final String detail;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.flag_outlined),
      label: Text('$label  •  $detail'),
    );
  }
}

class _ContinuousAyahRow extends ConsumerWidget {
  const _ContinuousAyahRow({
    required this.ayah,
    required this.isFirst,
    required this.isLast,
  });

  final Ayah ayah;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(
      bookmarkedAyahIdsProvider.select((ids) => ids.contains(ayah.id)),
    );
    final preferences =
        ref.watch(quranReadingPreferencesControllerProvider).asData?.value ??
        const QuranReadingPreferences();

    final transliteration = ayah.turkishTransliteration;
    final showTransliteration =
        preferences.showTransliteration &&
        transliteration != null &&
        transliteration.trim().isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.88),
            AppColors.sky.withValues(alpha: 0.56),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? 30 : 0),
          bottom: Radius.circular(isLast ? 30 : 0),
        ),
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.white.withValues(alpha: 0.70)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _AyahNumberBadge(number: ayah.ayahNumber),
                    const Spacer(),
                    IconButton(
                      tooltip: isBookmarked
                          ? 'Yer işaretinden kaldır'
                          : 'Yer işareti ekle',
                      onPressed: () {
                        ref
                            .read(quranBookmarksControllerProvider.notifier)
                            .toggleBookmark(ayah);
                      },
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked
                            ? AppColors.primary
                            : AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ayah.arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.arabic(context).copyWith(
                    fontSize: preferences.arabicTextSize,
                    height: 1.95,
                    color: AppColors.ink,
                  ),
                ),
                if (showTransliteration) ...[
                  const SizedBox(height: 14),
                  _SectionLabel(label: 'Okunuş'),
                  const SizedBox(height: 5),
                  Text(
                    transliteration,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.text,
                      height: 1.55,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (preferences.showTranslation) ...[
                  const SizedBox(height: 14),
                  const _SectionLabel(label: 'Meal'),
                  const SizedBox(height: 5),
                  Text(
                    ayah.turkishTranslation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.text,
                      fontSize: preferences.translationTextSize,
                      height: 1.58,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(lastReadControllerProvider.notifier).save(ayah);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kaldığınız yer kaydedildi.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Burada Kaldım'),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Divider(
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AyahNumberBadge extends StatelessWidget {
  const _AyahNumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          '$number',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
