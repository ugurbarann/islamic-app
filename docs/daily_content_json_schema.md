# Daily Content JSON Schema

Bundled daily content lives in:

`assets/data/daily_content_sample.json`

The root object must contain:

```json
{
  "metadata": {
    "source": "bundled",
    "contentVersion": 1,
    "lastSyncAt": "2026-06-16T00:00:00.000Z",
    "cachedUntil": "2026-07-16T00:00:00.000Z"
  },
  "bundles": []
}
```

Each bundle represents one day:

```json
{
  "dateKey": "2026-06-16",
  "metadata": {
    "source": "bundled",
    "contentVersion": 1
  },
  "items": []
}
```

Each item supports:

```json
{
  "id": "2026-06-16-dua",
  "type": "dua",
  "dateKey": "2026-06-16",
  "title": "Günün Duası",
  "arabicText": null,
  "turkishText": "Allah'ım bugün kalbimize huzur ver.",
  "turkishTransliteration": null,
  "source": "Yerel örnek",
  "category": "Günün Duası",
  "reference": null,
  "sortOrder": 3,
  "actionRoute": "/daily",
  "createdAt": "2026-06-16T00:00:00.000Z",
  "updatedAt": "2026-06-16T00:00:00.000Z",
  "validFrom": "2026-06-16T00:00:00.000Z",
  "validUntil": "2026-06-17T00:00:00.000Z"
}
```

## Required Fields

The parser requires:

- `id`
- `type`
- `dateKey`
- `title`
- `turkishText`

Supported `type` values:

- `ayah`
- `hadith`
- `dua`
- `knowledge`
- `quote`
- `surah_highlight`

Invalid items are skipped safely so the app does not crash.

## Content Accuracy Rule

Quran and hadith content must be entered only from verified sources. Placeholder sample ayah/hadith entries in the bundled JSON are intentionally marked as examples and must not be treated as verified religious text.

## Adding New JSON Content

To add new daily content:

1. Add a new bundle with `dateKey` in `YYYY-MM-DD` format.
2. Add one item for each desired daily card.
3. Increase `contentVersion`.
4. Run `flutter analyze`.
5. Open the Daily screen and Home screen to confirm no overflow or missing text.
