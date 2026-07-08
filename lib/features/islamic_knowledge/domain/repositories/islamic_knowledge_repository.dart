import '../entities/esmaul_husna_name.dart';
import '../entities/knowledge_article.dart';
import '../entities/knowledge_category.dart';

abstract class IslamicKnowledgeRepository {
  Future<List<KnowledgeCategory>> loadCategories();

  Future<List<KnowledgeArticle>> loadArticlesByCategory(String categoryId);

  Future<KnowledgeArticle> loadArticle(String articleId);

  Future<List<EsmaulHusnaName>> loadEsmaulHusnaNames();

  Future<EsmaulHusnaName> loadEsmaulHusnaName(int id);
}
