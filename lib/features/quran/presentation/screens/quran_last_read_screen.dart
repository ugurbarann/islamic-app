import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/quran_controller.dart';
import '../widgets/ayah_card.dart';

class QuranLastReadScreen extends ConsumerWidget {
  const QuranLastReadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadAsync = ref.watch(lastReadControllerProvider);

    return PremiumScaffold(
      title: 'Son Okunan',
      body: lastReadAsync.when(
        data: (ayah) {
          if (ayah == null) {
            return const PremiumStateView(
              title: 'Henüz son okunan ayet yok',
              icon: Icons.history_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
            children: [AyahCard(ayah: ayah, showLastReadAction: false)],
          );
        },
        loading: () => const PremiumStateView(
          title: 'Son okunan yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Son okunan yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
