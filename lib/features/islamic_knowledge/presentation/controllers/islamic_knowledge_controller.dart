import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_json_islamic_knowledge_data_source.dart';
import '../../data/repositories/local_islamic_knowledge_repository.dart';
import '../../domain/entities/esmaul_husna_name.dart';
import '../../domain/entities/knowledge_article.dart';
import '../../domain/entities/knowledge_category.dart';
import '../../domain/repositories/islamic_knowledge_repository.dart';

final islamicKnowledgeRepositoryProvider = Provider<IslamicKnowledgeRepository>(
  (ref) {
    return const LocalIslamicKnowledgeRepository(
      dataSource: LocalJsonIslamicKnowledgeDataSource(),
    );
  },
);

final knowledgeCategoriesProvider = FutureProvider<List<KnowledgeCategory>>((
  ref,
) {
  return ref.watch(islamicKnowledgeRepositoryProvider).loadCategories();
});

final knowledgeArticlesByCategoryProvider =
    FutureProvider.family<List<KnowledgeArticle>, String>((ref, categoryId) {
      return ref
          .watch(islamicKnowledgeRepositoryProvider)
          .loadArticlesByCategory(categoryId);
    });

final knowledgeArticleProvider =
    FutureProvider.family<KnowledgeArticle, String>((ref, articleId) {
      return ref
          .watch(islamicKnowledgeRepositoryProvider)
          .loadArticle(articleId);
    });

final esmaulHusnaNamesProvider = FutureProvider<List<EsmaulHusnaName>>((ref) {
  return ref.watch(islamicKnowledgeRepositoryProvider).loadEsmaulHusnaNames();
});

final esmaulHusnaNameProvider = FutureProvider.family<EsmaulHusnaName, int>((
  ref,
  id,
) {
  return ref.watch(islamicKnowledgeRepositoryProvider).loadEsmaulHusnaName(id);
});
