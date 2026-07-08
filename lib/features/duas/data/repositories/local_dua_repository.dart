import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/dua.dart';
import '../../domain/entities/dua_category.dart';
import '../../domain/entities/favorite_dua.dart';
import '../../domain/repositories/dua_repository.dart';
import '../datasources/local_json_dua_data_source.dart';

class LocalDuaRepository implements DuaRepository {
  const LocalDuaRepository({required this.dataSource});

  static const _favoritesKey = 'favorite_duas';

  final LocalJsonDuaDataSource dataSource;

  @override
  Future<List<DuaCategory>> loadCategories() async {
    final data = await dataSource.loadData();
    return data.map((item) => item.category).toList(growable: false);
  }

  @override
  Future<List<Dua>> loadDuasByCategory(String categoryId) async {
    final data = await dataSource.loadData();
    return data.firstWhere((item) => item.category.id == categoryId).duas;
  }

  @override
  Future<Dua> loadDua(String duaId) async {
    final data = await dataSource.loadData();
    return data
        .expand((item) => item.duas)
        .firstWhere((dua) => dua.id == duaId);
  }

  @override
  Future<List<FavoriteDua>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) {
      return const [];
    }

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) {
          final map = json as Map<String, dynamic>;
          return FavoriteDua(
            duaId: map['duaId'] as String,
            createdAt: DateTime.parse(map['createdAt'] as String),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<Dua>> loadFavoriteDuas() async {
    final favorites = await loadFavorites();
    final duas = <Dua>[];

    for (final favorite in favorites) {
      duas.add(await loadDua(favorite.duaId));
    }

    return duas;
  }

  @override
  Future<void> addFavorite(FavoriteDua favorite) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    final withoutDuplicate = favorites
        .where((item) => item.duaId != favorite.duaId)
        .toList();

    await prefs.setString(
      _favoritesKey,
      jsonEncode([
        ...withoutDuplicate.map(_favoriteToJson),
        _favoriteToJson(favorite),
      ]),
    );
  }

  @override
  Future<void> removeFavorite(String duaId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    await prefs.setString(
      _favoritesKey,
      jsonEncode(
        favorites
            .where((favorite) => favorite.duaId != duaId)
            .map(_favoriteToJson)
            .toList(),
      ),
    );
  }

  Map<String, dynamic> _favoriteToJson(FavoriteDua favorite) {
    return {
      'duaId': favorite.duaId,
      'createdAt': favorite.createdAt.toIso8601String(),
    };
  }
}
