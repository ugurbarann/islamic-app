import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/dua_controller.dart';

class FavoriteDuasScreen extends ConsumerWidget {
  const FavoriteDuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteDuasAsync = ref.watch(favoriteDuasControllerProvider);

    return PremiumScaffold(
      title: 'Favori Dualar',
      body: favoriteDuasAsync.when(
        data: (duas) {
          if (duas.isEmpty) {
            return const PremiumStateView(
              title: 'Henüz favori dua yok',
              icon: Icons.favorite_border_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
            itemCount: duas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final dua = duas[index];
              return PremiumListTile(
                leading: const Icon(Icons.favorite),
                title: dua.title,
                subtitle: dua.turkishText,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/duas/${dua.id}'),
              );
            },
          );
        },
        loading: () => const PremiumStateView(
          title: 'Favoriler yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Favoriler yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
