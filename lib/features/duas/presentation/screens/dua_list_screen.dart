import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/dua_controller.dart';

class DuaListScreen extends ConsumerWidget {
  const DuaListScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duasByCategoryProvider(categoryId));

    return PremiumScaffold(
      title: 'Dualar',
      body: duasAsync.when(
        data: (duas) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          itemCount: duas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final dua = duas[index];
            return PremiumListTile(
              leading: const Icon(Icons.favorite_border_outlined),
              title: dua.title,
              subtitle: dua.turkishText,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/duas/${dua.id}'),
            );
          },
        ),
        loading: () => const PremiumStateView(
          title: 'Dua listesi yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Dua listesi yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
