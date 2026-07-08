import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/shared_preferences_app_theme_preference_repository.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/repositories/app_theme_preference_repository.dart';

final appThemePreferenceRepositoryProvider =
    Provider<AppThemePreferenceRepository>((ref) {
      return const SharedPreferencesAppThemePreferenceRepository();
    });

final appThemeControllerProvider =
    AsyncNotifierProvider<AppThemeController, AppThemePreference>(
      AppThemeController.new,
    );

class AppThemeController extends AsyncNotifier<AppThemePreference> {
  @override
  Future<AppThemePreference> build() {
    return ref.watch(appThemePreferenceRepositoryProvider).loadPreference();
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    final current =
        state.asData?.value ??
        await ref.read(appThemePreferenceRepositoryProvider).loadPreference();
    final next = current.copyWith(darkModeEnabled: enabled);
    await ref.read(appThemePreferenceRepositoryProvider).savePreference(next);
    state = AsyncData(next);
  }
}
