import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/tasbih_session.dart';
import '../../domain/repositories/tasbih_repository.dart';

class SharedPreferencesTasbihRepository implements TasbihRepository {
  const SharedPreferencesTasbihRepository();

  static const _sessionsKey = 'tasbih_sessions';

  @override
  Future<List<TasbihSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);
    if (jsonString == null) {
      return const [];
    }

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    final sessions = jsonList.map((json) {
      final map = json as Map<String, dynamic>;
      return TasbihSession(
        id: map['id'] as String,
        title: map['title'] as String,
        count: map['count'] as int,
        savedAt: DateTime.parse(map['savedAt'] as String),
      );
    }).toList();

    sessions.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return sessions;
  }

  @override
  Future<TasbihSession?> loadLatestSession() async {
    final sessions = await loadSessions();
    if (sessions.isEmpty) {
      return null;
    }
    return sessions.first;
  }

  @override
  Future<void> saveSession(TasbihSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await loadSessions();
    await prefs.setString(
      _sessionsKey,
      jsonEncode([_toJson(session), ...sessions.map(_toJson)]),
    );
  }

  @override
  Future<void> clearSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
  }

  Map<String, dynamic> _toJson(TasbihSession session) {
    return {
      'id': session.id,
      'title': session.title,
      'count': session.count,
      'savedAt': session.savedAt.toIso8601String(),
    };
  }
}
