class AppConfig {
  const AppConfig._();

  static const privacyPolicyUrl =
      'https://ugurbarann.github.io/islamic-app/privacy-policy.html';
  static const supportUrl = 'https://ugurbarann.github.io/islamic-app/';

  static const mosqueBackendBaseUrl = String.fromEnvironment(
    'MOSQUE_BACKEND_BASE_URL',
    defaultValue: '',
  );

  static const reverseGeocodeBaseUrl = String.fromEnvironment(
    'REVERSE_GEOCODE_BASE_URL',
    defaultValue: 'https://nominatim.openstreetmap.org',
  );

  static const overpassBaseUrls = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  static List<String> get mosqueBackendBaseUrls {
    final value = mosqueBackendBaseUrl.trim();
    if (value.isEmpty) {
      return const [];
    }
    return [value.replaceFirst(RegExp(r'/+$'), '')];
  }
}
