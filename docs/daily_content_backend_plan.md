# Daily Content Backend Plan

This app currently reads daily content from bundled JSON and a local cache. The data layer is already split so Firebase can be added later without changing presentation widgets.

## Recommended Firebase Structure

Use Firestore collections:

- `daily_content/{dateKey}`: one document per day, for example `2026-06-16`.
- `daily_content_metadata/global`: global sync metadata.
- `content_versions/daily_content`: version and rollout metadata.

Suggested `daily_content/{dateKey}` document:

```json
{
  "dateKey": "2026-06-16",
  "metadata": {
    "source": "firebase",
    "contentVersion": 12,
    "lastSyncAt": "2026-06-15T18:00:00.000Z",
    "cachedUntil": "2026-07-16T00:00:00.000Z"
  },
  "items": []
}
```

## Admin Workflow

An admin can enter daily ayah, hadith, dua, Islamic knowledge, and optional surah highlight documents directly in Firebase Console or through a small admin panel later.

Quran and hadith text must be verified before publishing. Do not publish unverified ayah/hadith translations or references.

## App Sync Strategy

The app should request a rolling 30-day window around today:

- 15 days before today
- today
- 15 days after today

The repository saves valid remote bundles to local cache and deletes old bundles beyond the 30-day window. If Firebase is unavailable, the app falls back to cached content, then bundled JSON.

## Offline Behavior

The app must always work offline:

- First preference: cached Firebase content
- Second preference: bundled JSON sample/content
- If today's content is missing, show the latest available content with:
  `Bugünün içeriği henüz güncellenmedi. Kayıtlı içerik gösteriliyor.`

## Future Firebase Data Source

`FirebaseDailyContentDataSource` is currently a stub. When Firebase is configured, it should:

- Read documents from `daily_content`
- Validate every item before returning it
- Skip invalid items without crashing the app
- Read version metadata from `daily_content_metadata/global`
- Return only the requested 30-day window
