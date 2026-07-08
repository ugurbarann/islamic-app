import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/quran_controller.dart';
import '../widgets/ayah_card.dart';

class QuranBookmarksScreen extends ConsumerWidget {
  const QuranBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(quranBookmarksControllerProvider);

    return PremiumScaffold(
      title: 'Yer İşaretleri',
      body: bookmarksAsync.when(
        data: (ayahs) {
          if (ayahs.isEmpty) {
            return const PremiumStateView(
              title: 'Henüz yer işareti yok',
              icon: Icons.bookmark_border_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
            itemCount: ayahs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => AyahCard(ayah: ayahs[index]),
          );
        },
        loading: () => const PremiumStateView(
          title: 'Yer işaretleri yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Yer işaretleri yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
