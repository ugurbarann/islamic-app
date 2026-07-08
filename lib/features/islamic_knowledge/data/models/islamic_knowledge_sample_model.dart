import '../../domain/entities/esmaul_husna_name.dart';
import '../../domain/entities/knowledge_article.dart';
import '../../domain/entities/knowledge_category.dart';

class IslamicKnowledgeSampleModel {
  const IslamicKnowledgeSampleModel({
    required this.categories,
    required this.esmaulHusnaNames,
  });

  factory IslamicKnowledgeSampleModel.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>)
        .map((categoryJson) {
          final categoryMap = categoryJson as Map<String, dynamic>;
          final categoryId = categoryMap['id'] as String;
          final articles = (categoryMap['articles'] as List<dynamic>)
              .map((articleJson) {
                final articleMap = articleJson as Map<String, dynamic>;
                return KnowledgeArticle(
                  id: articleMap['id'] as String,
                  categoryId: categoryId,
                  title: articleMap['title'] as String,
                  summary: articleMap['summary'] as String,
                  body: articleMap['body'] as String,
                );
              })
              .toList(growable: false);

          return KnowledgeCategoryModel(
            category: KnowledgeCategory(
              id: categoryId,
              title: categoryMap['title'] as String,
              articleCount: articles.length,
            ),
            articles: articles,
          );
        })
        .toList(growable: false);

    final names = (json['esmaulHusna'] as List<dynamic>)
        .map((nameJson) {
          final nameMap = nameJson as Map<String, dynamic>;
          return EsmaulHusnaName(
            id: nameMap['id'] as int,
            arabicName: nameMap['arabicName'] as String,
            turkishName: nameMap['turkishName'] as String,
            meaning: nameMap['meaning'] as String,
            explanation: nameMap['explanation'] as String,
          );
        })
        .toList(growable: false);

    return IslamicKnowledgeSampleModel(
      categories: categories,
      esmaulHusnaNames: names,
    );
  }

  final List<KnowledgeCategoryModel> categories;
  final List<EsmaulHusnaName> esmaulHusnaNames;
}

class KnowledgeCategoryModel {
  const KnowledgeCategoryModel({
    required this.category,
    required this.articles,
  });

  final KnowledgeCategory category;
  final List<KnowledgeArticle> articles;
}
