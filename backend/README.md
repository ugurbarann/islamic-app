# Islamic App Backend

Lightweight Express backend for secure Google Places nearby mosque search.

## Setup

1. Copy `.env.example` to `.env`.
2. Put your Google Places API key in `.env`:

```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
PORT=3000
```

3. Install and run:

```bash
npm install
npm run dev
```

Production-style start:

```bash
npm start
```

## Endpoint

```http
GET /api/nearby-mosques?lat=41.0082&lng=28.9784&radius=3000
```

Response:

```json
{
  "items": [
    {
      "id": "place_id",
      "name": "Cami adı",
      "address": "Adres",
      "latitude": 41.0,
      "longitude": 28.9,
      "distanceMeters": 240
    }
  ],
  "cached": false
}
```

## Security

The Google Places API key must only live in `backend/.env`. Do not put it in Flutter, Dart, docs, generated logs, or committed files. `backend/.env` is ignored by git.

## Daily Content Firebase Upload

Generate a 30-day daily content seed from the app's bundled verified content.
When no date is supplied, generation starts from the current UTC date:

```bash
npm run generate:daily-content -- 2026-07-11 30 --update-local
```

This writes:

```text
backend/seeds/daily_content_2026-07-11_30_days.json
```

`--update-local` also refreshes the app's bundled offline fallback. Keep only
the current seed in source control to avoid uploading stale sample content.

To upload it to Firestore, download a Firebase service account private key from:

```text
Firebase Console > Project settings > Service accounts > Generate new private key
```

Save it outside source control, then run:

```powershell
$env:FIREBASE_SERVICE_ACCOUNT_PATH="C:\path\to\service-account.json"
npm run upload:daily-content
```

The uploader writes one document per day into:

```text
daily_content/{YYYY-MM-DD}
```

## Production mobile configuration

Deploy this backend over HTTPS, then add its public base URL to Codemagic's
secure `ugur` environment group as `MOSQUE_BACKEND_BASE_URL`. Both iOS
workflows pass that value to Flutter at build time. The mobile app uses public
OpenStreetMap endpoints only as a best-effort fallback when the backend is not
configured or temporarily unavailable.

## Wallpaper Firebase Upload

The Flutter app currently uses bundled optimized wallpaper assets. Remote
wallpaper download is prepared only on the backend side for a later frontend
integration.

Upload the current bundled wallpaper set to Firebase Storage and write catalog
metadata to Firestore:

```powershell
$env:FIREBASE_SERVICE_ACCOUNT_PATH="C:\path\to\service-account.json"
npm run upload:wallpapers
```

This writes image files to:

```text
wallpapers/full
wallpapers/thumbs
```

and Firestore metadata to:

```text
wallpaper_catalog/{wallpaperId}
wallpaper_catalog_metadata/current
```
