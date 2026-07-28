import 'package:shared_preferences/shared_preferences.dart';

class AdFrequencyPolicy {
  const AdFrequencyPolicy({
    this.minimumInterval = const Duration(minutes: 10),
    this.hourlyLimit = 4,
    this.dailyLimit = 8,
    this.adFreeLaunches = 0,
  });

  final Duration minimumInterval;
  final int hourlyLimit;
  final int dailyLimit;
  final int adFreeLaunches;

  bool canShow({
    required DateTime now,
    required int launchCount,
    required List<DateTime> impressions,
    DateTime? lastDismissedAt,
  }) {
    if (launchCount <= adFreeLaunches) {
      return false;
    }

    final normalizedNow = now.toUtc();
    final recentImpressions = impressions
        .map((value) => value.toUtc())
        .toList(growable: false);
    final lastImpression = recentImpressions.isEmpty
        ? null
        : recentImpressions.reduce((a, b) => a.isAfter(b) ? a : b);
    final lastCooldownEvent = _latest(lastImpression, lastDismissedAt?.toUtc());

    if (lastCooldownEvent != null &&
        normalizedNow.difference(lastCooldownEvent) < minimumInterval) {
      return false;
    }

    final hourlyStart = normalizedNow.subtract(const Duration(hours: 1));
    final hourlyCount = recentImpressions
        .where((value) => value.isAfter(hourlyStart))
        .length;
    if (hourlyCount >= hourlyLimit) {
      return false;
    }

    final dailyStart = normalizedNow.subtract(const Duration(hours: 24));
    final dailyCount = recentImpressions
        .where((value) => value.isAfter(dailyStart))
        .length;
    return dailyCount < dailyLimit;
  }

  DateTime? _latest(DateTime? first, DateTime? second) {
    if (first == null) {
      return second;
    }
    if (second == null) {
      return first;
    }
    return first.isAfter(second) ? first : second;
  }
}

class AdFrequencyStore {
  const AdFrequencyStore({
    this.policy = const AdFrequencyPolicy(),
    this.now = DateTime.now,
  });

  static const _launchCountKey = 'app_open_ad_launch_count_v1';
  static const _impressionsKey = 'app_open_ad_impressions_v1';
  static const _lastDismissedAtKey = 'app_open_ad_last_dismissed_at_v1';

  final AdFrequencyPolicy policy;
  final DateTime Function() now;

  Future<int> registerLaunch() async {
    final preferences = await SharedPreferences.getInstance();
    final launchCount = (preferences.getInt(_launchCountKey) ?? 0) + 1;
    await preferences.setInt(_launchCountKey, launchCount);
    return launchCount;
  }

  Future<bool> canShow({required int launchCount}) async {
    final preferences = await SharedPreferences.getInstance();
    final currentTime = now().toUtc();
    final impressions = _readImpressions(preferences);
    final lastDismissedAt = _readDate(
      preferences.getString(_lastDismissedAtKey),
    );

    await _pruneOldImpressions(preferences, impressions, currentTime);

    return policy.canShow(
      now: currentTime,
      launchCount: launchCount,
      impressions: impressions,
      lastDismissedAt: lastDismissedAt,
    );
  }

  Future<void> recordImpression() async {
    final preferences = await SharedPreferences.getInstance();
    final currentTime = now().toUtc();
    final impressions = _readImpressions(preferences)
      ..removeWhere(
        (value) => currentTime.difference(value) >= const Duration(hours: 24),
      )
      ..add(currentTime);
    await preferences.setStringList(
      _impressionsKey,
      impressions.map((value) => value.toIso8601String()).toList(),
    );
  }

  Future<void> recordDismissal() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastDismissedAtKey,
      now().toUtc().toIso8601String(),
    );
  }

  List<DateTime> _readImpressions(SharedPreferences preferences) {
    return (preferences.getStringList(_impressionsKey) ?? const <String>[])
        .map(_readDate)
        .whereType<DateTime>()
        .map((value) => value.toUtc())
        .toList();
  }

  DateTime? _readDate(String? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  Future<void> _pruneOldImpressions(
    SharedPreferences preferences,
    List<DateTime> impressions,
    DateTime currentTime,
  ) async {
    final retained = impressions
        .where(
          (value) => currentTime.difference(value) < const Duration(hours: 24),
        )
        .toList(growable: false);
    if (retained.length == impressions.length) {
      return;
    }
    await preferences.setStringList(
      _impressionsKey,
      retained.map((value) => value.toIso8601String()).toList(),
    );
  }
}
