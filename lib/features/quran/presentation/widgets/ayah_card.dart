import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/glass_panel.dart';
import '../../domain/entities/ayah.dart';
import '../controllers/quran_controller.dart';

class AyahCard extends ConsumerWidget {
  const AyahCard({
    required this.ayah,
    this.showLastReadAction = true,
    super.key,
  });

  final Ayah ayah;
  final bool showLastReadAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedAyahs = ref.watch(quranBookmarksControllerProvider);
    final isBookmarked = bookmarkedAyahs.maybeWhen(
      data: (ayahs) => ayahs.any((item) => item.id == ayah.id),
      orElse: () => false,
    );

    return GlassPanel(
      borderRadius: 24,
      shadow: false,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '${ayah.surahNumber}:${ayah.ayahNumber}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
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
                    isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ayah.arabicText,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.headlineSmall,
              textDirection: TextDirection.rtl,
            ),
            if (ayah.turkishTransliteration != null &&
                ayah.turkishTransliteration!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Okunuş', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(ayah.turkishTransliteration!),
            ],
            const SizedBox(height: 12),
            Text('Meal', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(ayah.turkishTranslation),
            if (showLastReadAction) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(lastReadControllerProvider.notifier).save(ayah);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Son okunan kaydedildi.')),
                    );
                  },
                  icon: const Icon(Icons.history_outlined),
                  label: const Text('Son okunan yap'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
