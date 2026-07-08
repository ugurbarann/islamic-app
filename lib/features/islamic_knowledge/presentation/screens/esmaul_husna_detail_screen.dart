import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/islamic_knowledge_controller.dart';

class EsmaulHusnaDetailScreen extends ConsumerWidget {
  const EsmaulHusnaDetailScreen({required this.nameId, super.key});

  final int nameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(esmaulHusnaNameProvider(nameId));

    return PremiumScaffold(
      title: 'Esmaül Hüsna',
      body: nameAsync.when(
        data: (name) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          children: [
            GlassPanel(
              borderRadius: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name.arabicName,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    name.turkishName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Anlamı', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(name.meaning),
                  const SizedBox(height: 16),
                  Text(
                    'Açıklama',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(name.explanation),
                ],
              ),
            ),
          ],
        ),
        loading: () => const PremiumStateView(
          title: 'İsim detayı yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'İsim detayı yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
