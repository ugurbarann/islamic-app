import '../../domain/entities/dua.dart';
import '../../domain/entities/dua_category.dart';

class DuaCategoryModel {
  const DuaCategoryModel({required this.category, required this.duas});

  factory DuaCategoryModel.fromJson(Map<String, dynamic> json) {
    final categoryId = json['id'] as String;
    final duas = (json['duas'] as List<dynamic>)
        .map((duaJson) {
          final duaMap = duaJson as Map<String, dynamic>;
          return Dua(
            id: duaMap['id'] as String,
            categoryId: categoryId,
            title: duaMap['title'] as String,
            arabicText: duaMap['arabicText'] as String?,
            turkishTransliteration: duaMap['turkishTransliteration'] as String?,
            turkishText: duaMap['turkishText'] as String,
            source: duaMap['source'] as String?,
          );
        })
        .toList(growable: false);

    return DuaCategoryModel(
      category: DuaCategory(
        id: categoryId,
        title: json['title'] as String,
        duaCount: duas.length,
      ),
      duas: duas,
    );
  }

  final DuaCategory category;
  final List<Dua> duas;
}
