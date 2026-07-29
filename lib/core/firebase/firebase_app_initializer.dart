import 'package:firebase_core/firebase_core.dart';

class FirebaseAppInitializer {
  FirebaseAppInitializer._();

  static Future<FirebaseApp>? _initialization;

  static Future<FirebaseApp> ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    final pending = _initialization;
    if (pending != null) {
      return pending;
    }

    final initialization = Firebase.initializeApp();
    _initialization = initialization;
    try {
      return await initialization;
    } catch (_) {
      if (identical(_initialization, initialization)) {
        _initialization = null;
      }
      rethrow;
    }
  }
}
