import '../entities/tasbih_session.dart';

abstract class TasbihRepository {
  Future<List<TasbihSession>> loadSessions();

  Future<TasbihSession?> loadLatestSession();

  Future<void> saveSession(TasbihSession session);

  Future<void> clearSessions();
}
