import '../../domain/entities/esmaul_husna_name.dart';
import '../../domain/entities/knowledge_article.dart';
import '../../domain/entities/knowledge_category.dart';
import '../../domain/repositories/islamic_knowledge_repository.dart';
import '../datasources/local_json_islamic_knowledge_data_source.dart';

class LocalIslamicKnowledgeRepository implements IslamicKnowledgeRepository {
  const LocalIslamicKnowledgeRepository({required this.dataSource});

  final LocalJsonIslamicKnowledgeDataSource dataSource;

  @override
  Future<List<KnowledgeCategory>> loadCategories() async {
    final data = await dataSource.loadData();
    return data.categories.map((item) => item.category).toList(growable: false);
  }

  @override
  Future<List<KnowledgeArticle>> loadArticlesByCategory(
    String categoryId,
  ) async {
    final data = await dataSource.loadData();
    return data.categories
        .firstWhere((item) => item.category.id == categoryId)
        .articles;
  }

  @override
  Future<KnowledgeArticle> loadArticle(String articleId) async {
    final data = await dataSource.loadData();
    return data.categories
        .expand((item) => item.articles)
        .firstWhere((article) => article.id == articleId);
  }

  @override
  Future<List<EsmaulHusnaName>> loadEsmaulHusnaNames() async {
    final data = await dataSource.loadData();
    return data.esmaulHusnaNames;
  }

  @override
  Future<EsmaulHusnaName> loadEsmaulHusnaName(int id) async {
    final data = await dataSource.loadData();
    return data.esmaulHusnaNames.firstWhere((name) => name.id == id);
  }
}
