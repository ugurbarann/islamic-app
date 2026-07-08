import '../entities/dua.dart';
import '../entities/dua_category.dart';
import '../entities/favorite_dua.dart';

abstract class DuaRepository {
  Future<List<DuaCategory>> loadCategories();

  Future<List<Dua>> loadDuasByCategory(String categoryId);

  Future<Dua> loadDua(String duaId);

  Future<List<FavoriteDua>> loadFavorites();

  Future<List<Dua>> loadFavoriteDuas();

  Future<void> addFavorite(FavoriteDua favorite);

  Future<void> removeFavorite(String duaId);
}
