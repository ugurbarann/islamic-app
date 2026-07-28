import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/ads/ad_frequency_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AdFrequencyPolicy', () {
    const policy = AdFrequencyPolicy();
    final now = DateTime.utc(2026, 7, 28, 12);

    test('allows the first launch when no frequency cap applies', () {
      expect(
        policy.canShow(now: now, launchCount: 1, impressions: const []),
        isTrue,
      );
    });

    test('starts the ten-minute cooldown again after dismissal', () {
      final impression = now.subtract(const Duration(minutes: 20));
      final dismissal = now.subtract(const Duration(minutes: 9));

      expect(
        policy.canShow(
          now: now,
          launchCount: 1,
          impressions: [impression],
          lastDismissedAt: dismissal,
        ),
        isFalse,
      );
      expect(
        policy.canShow(
          now: now.add(const Duration(minutes: 1)),
          launchCount: 1,
          impressions: [impression],
          lastDismissedAt: dismissal,
        ),
        isTrue,
      );
    });

    test('allows at most four impressions in a rolling hour', () {
      final impressions = [
        now.subtract(const Duration(minutes: 55)),
        now.subtract(const Duration(minutes: 40)),
        now.subtract(const Duration(minutes: 25)),
        now.subtract(const Duration(minutes: 10)),
      ];

      expect(
        policy.canShow(now: now, launchCount: 1, impressions: impressions),
        isFalse,
      );
    });

    test('allows at most eight impressions in rolling 24 hours', () {
      final impressions = List.generate(
        8,
        (index) => now.subtract(Duration(hours: index + 1)),
      );

      expect(
        policy.canShow(now: now, launchCount: 1, impressions: impressions),
        isFalse,
      );
    });
  });

  test('persists cooldown across store instances', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime.utc(2026, 7, 28, 12);
    final firstStore = AdFrequencyStore(now: () => now);

    final launchCount = await firstStore.registerLaunch();
    expect(await firstStore.canShow(launchCount: launchCount), isTrue);

    await firstStore.recordImpression();
    await firstStore.recordDismissal();

    now = now.add(const Duration(minutes: 9));
    final restoredStore = AdFrequencyStore(now: () => now);
    expect(await restoredStore.canShow(launchCount: launchCount), isFalse);

    now = now.add(const Duration(minutes: 1));
    expect(await restoredStore.canShow(launchCount: launchCount), isTrue);
  });
}
