class DailyContentMetadata {
  const DailyContentMetadata({
    required this.source,
    required this.contentVersion,
    this.lastSyncAt,
    this.cachedUntil,
    this.fallbackMessage,
  });

  final String source;
  final int contentVersion;
  final DateTime? lastSyncAt;
  final DateTime? cachedUntil;
  final String? fallbackMessage;

  DailyContentMetadata copyWith({
    String? source,
    int? contentVersion,
    DateTime? lastSyncAt,
    DateTime? cachedUntil,
    String? fallbackMessage,
  }) {
    return DailyContentMetadata(
      source: source ?? this.source,
      contentVersion: contentVersion ?? this.contentVersion,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      cachedUntil: cachedUntil ?? this.cachedUntil,
      fallbackMessage: fallbackMessage,
    );
  }
}
