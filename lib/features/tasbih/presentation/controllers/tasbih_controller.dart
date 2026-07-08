import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/shared_preferences_tasbih_preferences_repository.dart';
import '../../data/repositories/shared_preferences_tasbih_repository.dart';
import '../../domain/entities/tasbih_preferences.dart';
import '../../domain/entities/tasbih_session.dart';
import '../../domain/repositories/tasbih_preferences_repository.dart';
import '../../domain/repositories/tasbih_repository.dart';

final tasbihRepositoryProvider = Provider<TasbihRepository>((ref) {
  return const SharedPreferencesTasbihRepository();
});

final tasbihPreferencesRepositoryProvider =
    Provider<TasbihPreferencesRepository>((ref) {
      return const SharedPreferencesTasbihPreferencesRepository();
    });

final tasbihPreferencesControllerProvider =
    AsyncNotifierProvider<TasbihPreferencesController, TasbihPreferences>(
      TasbihPreferencesController.new,
    );

class TasbihPreferencesController extends AsyncNotifier<TasbihPreferences> {
  @override
  Future<TasbihPreferences> build() {
    return ref.watch(tasbihPreferencesRepositoryProvider).loadPreferences();
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    final current =
        state.asData?.value ??
        await ref.read(tasbihPreferencesRepositoryProvider).loadPreferences();
    final updated = current.copyWith(hapticFeedbackEnabled: enabled);
    await ref
        .read(tasbihPreferencesRepositoryProvider)
        .savePreferences(updated);
    state = AsyncData(updated);
  }
}

final tasbihControllerProvider =
    AsyncNotifierProvider<TasbihController, TasbihState>(TasbihController.new);

class TasbihState {
  const TasbihState({required this.count, required this.sessions});

  final int count;
  final List<TasbihSession> sessions;

  TasbihState copyWith({int? count, List<TasbihSession>? sessions}) {
    return TasbihState(
      count: count ?? this.count,
      sessions: sessions ?? this.sessions,
    );
  }
}

class TasbihController extends AsyncNotifier<TasbihState> {
  @override
  Future<TasbihState> build() async {
    final sessions = await ref.watch(tasbihRepositoryProvider).loadSessions();
    return TasbihState(count: 0, sessions: sessions);
  }

  void increment() {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(count: current.count + 1));
  }

  void reset() {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(count: 0));
  }

  Future<void> continueLatestSession() async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    final latestSession = await ref
        .read(tasbihRepositoryProvider)
        .loadLatestSession();
    if (latestSession == null) {
      return;
    }

    state = AsyncData(current.copyWith(count: latestSession.count));
  }

  Future<void> saveSession() async {
    final current = state.asData?.value;
    if (current == null || current.count == 0) {
      return;
    }

    final now = DateTime.now();
    final session = TasbihSession(
      id: now.microsecondsSinceEpoch.toString(),
      count: current.count,
      savedAt: now,
    );
    final repository = ref.read(tasbihRepositoryProvider);
    await repository.saveSession(session);
    state = AsyncData(
      current.copyWith(sessions: await repository.loadSessions()),
    );
  }

  Future<bool> clearHistory() async {
    final current = state.asData?.value;
    if (current == null || current.sessions.isEmpty) {
      return false;
    }

    await ref.read(tasbihRepositoryProvider).clearSessions();
    state = AsyncData(current.copyWith(sessions: const []));
    return true;
  }
}
