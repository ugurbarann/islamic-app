import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_design_system.dart';
import '../../../../shared/widgets/app_illustrations.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/widgets/premium_scaffold.dart';
import '../../domain/entities/knowledge_category.dart';
import '../controllers/islamic_knowledge_controller.dart';

class IslamicKnowledgeScreen extends ConsumerWidget {
  const IslamicKnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(knowledgeCategoriesProvider);

    return PremiumScaffold(
      title: 'İslami Bilgiler',
      body: categoriesAsync.when(
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _KnowledgeCategoryCard(category: category),
            );
          },
        ),
        loading: () => const PremiumStateView(
          title: 'İslami bilgiler yükleniyor',
          loading: true,
        ),
        error: (error, stackTrace) => PremiumStateView(
          title: 'İslami bilgiler yüklenemedi',
          message: error.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _KnowledgeCategoryCard extends StatelessWidget {
  const _KnowledgeCategoryCard({required this.category});

  final KnowledgeCategory category;

  @override
  Widget build(BuildContext context) {
    final meta = _KnowledgeCategoryMeta.forId(category.id);

    return GlassPanel(
      borderRadius: 30,
      padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
      shadow: false,
      onTap: () {
        if (category.id == 'asmaul_husna') {
          context.push('/knowledge/esmaul-husna');
        } else {
          context.push('/knowledge/category/${category.id}');
        }
      },
      child: Row(
        children: [
          _KnowledgeIconBadge(meta: meta),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  meta.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${category.articleCount} yazı',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.70),
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.ink,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeIconBadge extends StatelessWidget {
  const _KnowledgeIconBadge({required this.meta});

  final _KnowledgeCategoryMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.96),
            meta.softColor.withValues(alpha: 0.72),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
      ),
      child: Center(
        child: AppIllustration(
          kind: meta.icon,
          size: 36,
          primary: meta.primary,
          accent: meta.accent,
        ),
      ),
    );
  }
}

class _KnowledgeCategoryMeta {
  const _KnowledgeCategoryMeta({
    required this.description,
    required this.icon,
    required this.primary,
    required this.accent,
    required this.softColor,
  });

  final String description;
  final AppIllustrationKind icon;
  final Color primary;
  final Color accent;
  final Color softColor;

  static _KnowledgeCategoryMeta forId(String id) {
    return switch (id) {
      'daily' => const _KnowledgeCategoryMeta(
        description: 'Günlük ahlak rehberi',
        icon: AppIllustrationKind.knowledge,
        primary: AppColors.primary,
        accent: AppColors.warning,
        softColor: Color(0xFFE3F3FF),
      ),
      'prophets' => const _KnowledgeCategoryMeta(
        description: 'Peygamber kıssaları',
        icon: AppIllustrationKind.quran,
        primary: Color(0xFF1769C2),
        accent: Color(0xFFF3B33E),
        softColor: Color(0xFFEAF5FF),
      ),
      'sahaba' => const _KnowledgeCategoryMeta(
        description: 'Sahabe hayatlarından dersler',
        icon: AppIllustrationKind.crescent,
        primary: Color(0xFF2873D9),
        accent: Color(0xFFF2B544),
        softColor: Color(0xFFEFF6FF),
      ),
      'history' => const _KnowledgeCategoryMeta(
        description: 'Hicret ve medeniyet',
        icon: AppIllustrationKind.mosque,
        primary: Color(0xFF1C6ECF),
        accent: Color(0xFFEDB23C),
        softColor: Color(0xFFE8F6FF),
      ),
      'asmaul_husna' => const _KnowledgeCategoryMeta(
        description: 'Allah’ın 99 adı',
        icon: AppIllustrationKind.esma,
        primary: Color(0xFF226ED6),
        accent: Color(0xFFE6A72F),
        softColor: Color(0xFFF1F5FF),
      ),
      _ => const _KnowledgeCategoryMeta(
        description: 'İslami bilgi yazıları',
        icon: AppIllustrationKind.knowledge,
        primary: AppColors.primary,
        accent: AppColors.warning,
        softColor: AppColors.primarySoft,
      ),
    };
  }
}
