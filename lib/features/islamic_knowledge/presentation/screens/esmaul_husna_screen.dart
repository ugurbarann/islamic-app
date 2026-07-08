import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/islamic_knowledge_controller.dart';

class EsmaulHusnaScreen extends ConsumerWidget {
  const EsmaulHusnaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final namesAsync = ref.watch(esmaulHusnaNamesProvider);

    return PremiumScaffold(
      title: 'Esmaül Hüsna',
      body: namesAsync.when(
        data: (names) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          itemCount: names.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final name = names[index];
            return PremiumListTile(
              leading: CircleAvatar(child: Text('${name.id}')),
              title: name.turkishName,
              subtitle: name.meaning,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/knowledge/esmaul-husna/${name.id}'),
            );
          },
        ),
        loading: () => const PremiumStateView(
          title: 'Esmaül Hüsna yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Esmaül Hüsna yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
