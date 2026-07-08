import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_json_dua_data_source.dart';
import '../../data/repositories/local_dua_repository.dart';
import '../../domain/entities/dua.dart';
import '../../domain/entities/dua_category.dart';
import '../../domain/entities/favorite_dua.dart';
import '../../domain/repositories/dua_repository.dart';

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  return const LocalDuaRepository(dataSource: LocalJsonDuaDataSource());
});

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) {
  return ref.watch(duaRepositoryProvider).loadCategories();
});

final duasByCategoryProvider = FutureProvider.family<List<Dua>, String>((
  ref,
  categoryId,
) {
  return ref.watch(duaRepositoryProvider).loadDuasByCategory(categoryId);
});

final duaDetailProvider = FutureProvider.family<Dua, String>((ref, duaId) {
  return ref.watch(duaRepositoryProvider).loadDua(duaId);
});

final favoriteDuasControllerProvider =
    AsyncNotifierProvider<FavoriteDuasController, List<Dua>>(
      FavoriteDuasController.new,
    );

class FavoriteDuasController extends AsyncNotifier<List<Dua>> {
  @override
  Future<List<Dua>> build() {
    return ref.watch(duaRepositoryProvider).loadFavoriteDuas();
  }

  Future<void> toggleFavorite(Dua dua) async {
    final repository = ref.read(duaRepositoryProvider);
    final favorites = await repository.loadFavorites();
    final isFavorite = favorites.any((favorite) => favorite.duaId == dua.id);

    if (isFavorite) {
      await repository.removeFavorite(dua.id);
    } else {
      await repository.addFavorite(
        FavoriteDua(duaId: dua.id, createdAt: DateTime.now()),
      );
    }

    state = AsyncData(await repository.loadFavoriteDuas());
  }
}
