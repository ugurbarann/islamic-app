class AppConfig {
  const AppConfig._();

  static const mosqueBackendBaseUrl = String.fromEnvironment(
    'MOSQUE_BACKEND_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static List<String> get mosqueBackendBaseUrls {
    return _candidateUrls(mosqueBackendBaseUrl);
  }

  static List<String> _candidateUrls(String baseUrl) {
    final isDefaultLocalhost = baseUrl == 'http://127.0.0.1:3000';
    final urls = <String>[
      if (isDefaultLocalhost) 'http://192.168.1.37:3000',
      if (isDefaultLocalhost) 'http://192.168.1.35:3000',
      if (isDefaultLocalhost) 'http://10.0.2.2:3000',
      baseUrl,
      if (!isDefaultLocalhost) 'http://192.168.1.37:3000',
      if (!isDefaultLocalhost) 'http://192.168.1.35:3000',
      if (!isDefaultLocalhost) 'http://10.0.2.2:3000',
    ];

    return urls.toSet().toList(growable: false);
  }
}
