import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../controllers/islamic_knowledge_controller.dart';

class KnowledgeArticleDetailScreen extends ConsumerWidget {
  const KnowledgeArticleDetailScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(knowledgeArticleProvider(articleId));

    return PremiumScaffold(
      title: 'Yazı Detayı',
      body: articleAsync.when(
        data: (article) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          children: [
            GlassPanel(
              borderRadius: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article.body,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () =>
            const PremiumStateView(title: 'Yazı yükleniyor', loading: true),
        error: (error, stackTrace) => PremiumStateView(
          title: 'Yazı yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
