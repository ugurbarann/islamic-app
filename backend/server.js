import cors from "cors";
import dotenv from "dotenv";
import express from "express";

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 3000);
const googleMapsApiKey = process.env.GOOGLE_MAPS_API_KEY;
const cache = new Map();
const cacheTtlMs = 24 * 60 * 60 * 1000;

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ ok: true });
});

app.get("/api/nearby-mosques", async (req, res) => {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const requestedRadius = Number(req.query.radius || 3000);
  const requestedLimit = Number(req.query.limit || 10);

  if (!Number.isFinite(lat) || lat < -90 || lat > 90) {
    return res.status(400).json({ error: "invalid_lat", items: [] });
  }

  if (!Number.isFinite(lng) || lng < -180 || lng > 180) {
    return res.status(400).json({ error: "invalid_lng", items: [] });
  }

  const radius = clamp(
    Number.isFinite(requestedRadius) ? requestedRadius : 3000,
    1,
    5000,
  );
  const limit = clamp(Number.isFinite(requestedLimit) ? requestedLimit : 10, 1, 10);
  const cacheKey = `${roundForCache(lat)}:${roundForCache(lng)}:${radius}`;
  const cached = cache.get(cacheKey);

  if (cached && Date.now() - cached.createdAt < cacheTtlMs) {
    return res.json({ items: cached.items, cached: true });
  }

  if (!googleMapsApiKey) {
    return res
      .status(500)
      .json({ error: "missing_google_maps_api_key", items: [] });
  }

  try {
    const googleResponse = await fetch(
      "https://places.googleapis.com/v1/places:searchNearby",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": googleMapsApiKey,
          "X-Goog-FieldMask":
            "places.id,places.displayName,places.formattedAddress,places.shortFormattedAddress,places.addressComponents,places.plusCode,places.location",
        },
        body: JSON.stringify({
          includedTypes: ["mosque"],
          maxResultCount: limit,
          languageCode: "tr",
          rankPreference: "DISTANCE",
          locationRestriction: {
            circle: {
              center: { latitude: lat, longitude: lng },
              radius,
            },
          },
        }),
      },
    );

    if (!googleResponse.ok) {
      const safeStatus = googleResponse.status;
      return res.status(502).json({
        error: "google_places_unavailable",
        status: safeStatus,
        items: [],
      });
    }

    const payload = await googleResponse.json();
    const items = (payload.places || [])
      .map((place) => toMosque(place, lat, lng))
      .filter(Boolean)
      .sort((a, b) => a.distanceMeters - b.distanceMeters)
      .slice(0, limit);

    cache.set(cacheKey, { createdAt: Date.now(), items });
    return res.json({ items, cached: false });
  } catch (error) {
    return res.status(502).json({
      error: "nearby_mosques_unavailable",
      items: [],
    });
  }
});

app.get("/api/reverse-geocode", async (req, res) => {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);

  if (!Number.isFinite(lat) || lat < -90 || lat > 90) {
    return res.status(400).json({ error: "invalid_lat" });
  }

  if (!Number.isFinite(lng) || lng < -180 || lng > 180) {
    return res.status(400).json({ error: "invalid_lng" });
  }

  if (!googleMapsApiKey) {
    return res.status(500).json({ error: "missing_google_maps_api_key" });
  }

  try {
    const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
    url.searchParams.set("latlng", `${lat},${lng}`);
    url.searchParams.set("language", "tr");
    url.searchParams.set("key", googleMapsApiKey);

    const googleResponse = await fetch(url);
    if (!googleResponse.ok) {
      return res.status(502).json({
        error: "google_geocode_unavailable",
        status: googleResponse.status,
      });
    }

    const payload = await googleResponse.json();
    if (payload.status !== "OK" || !Array.isArray(payload.results)) {
      return res.status(404).json({
        error: "location_not_resolved",
        status: payload.status,
      });
    }

    const resolved = resolveTurkishAdministrativeLocation(payload.results);
    if (!resolved.city && !resolved.district) {
      return res.status(404).json({ error: "location_not_supported" });
    }

    return res.json(resolved);
  } catch (error) {
    return res.status(502).json({ error: "reverse_geocode_unavailable" });
  }
});

app.listen(port, () => {
  console.log(`Islamic App backend listening on http://localhost:${port}`);
});

function resolveTurkishAdministrativeLocation(results) {
  let city = "";
  let district = "";

  for (const result of results) {
    const components = result.address_components || [];
    city ||= componentLongName(components, "administrative_area_level_1");
    district ||=
      componentLongName(components, "administrative_area_level_2") ||
      componentLongName(components, "locality") ||
      componentLongName(components, "sublocality_level_1") ||
      componentLongName(components, "administrative_area_level_3");

    if (city && district) {
      break;
    }
  }

  return {
    city: stripAdministrativeSuffix(city),
    district: stripAdministrativeSuffix(district),
  };
}

function componentLongName(components, type) {
  const component = components.find((item) => item.types?.includes(type));
  return cleanText(component?.long_name || component?.short_name);
}

function stripAdministrativeSuffix(value) {
  return cleanText(value)
    .replace(/\s+(Province|İli|Ili)$/i, "")
    .replace(/\s+(District|İlçesi|Ilcesi)$/i, "");
}

function toMosque(place, originLat, originLng) {
  const latitude = Number(place.location?.latitude);
  const longitude = Number(place.location?.longitude);
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
    return null;
  }

  return {
    id: String(place.id || `${latitude},${longitude}`),
    name: cleanText(place.displayName?.text) || "Cami",
    address: resolveAddress(place, latitude, longitude),
    latitude,
    longitude,
    distanceMeters: Math.round(
      distanceInMeters(originLat, originLng, latitude, longitude),
    ),
  };
}

function resolveAddress(place, latitude, longitude) {
  return (
    cleanText(place.formattedAddress) ||
    cleanText(place.shortFormattedAddress) ||
    addressFromComponents(place.addressComponents) ||
    cleanText(place.plusCode?.compoundCode) ||
    `${latitude.toFixed(5)}, ${longitude.toFixed(5)}`
  );
}

function addressFromComponents(components) {
  if (!Array.isArray(components)) {
    return "";
  }

  const wantedTypes = new Set([
    "neighborhood",
    "sublocality",
    "sublocality_level_1",
    "locality",
    "administrative_area_level_2",
    "administrative_area_level_1",
  ]);
  const parts = [];
  for (const component of components) {
    const types = component.types || [];
    if (types.some((type) => wantedTypes.has(type))) {
      const name = cleanText(component.longText || component.shortText);
      if (name && !parts.includes(name)) {
        parts.push(name);
      }
    }
  }
  return parts.slice(0, 3).join(", ");
}

function cleanText(value) {
  if (typeof value !== "string") {
    return "";
  }
  return value.replace(/\s+/g, " ").trim();
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function roundForCache(value) {
  return Math.round(value * 100) / 100;
}

function distanceInMeters(
  startLatitude,
  startLongitude,
  endLatitude,
  endLongitude,
) {
  const earthRadiusMeters = 6371000;
  const startLatRad = degreesToRadians(startLatitude);
  const endLatRad = degreesToRadians(endLatitude);
  const deltaLat = degreesToRadians(endLatitude - startLatitude);
  const deltaLon = degreesToRadians(endLongitude - startLongitude);

  const a =
    Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
    Math.cos(startLatRad) *
      Math.cos(endLatRad) *
      Math.sin(deltaLon / 2) *
      Math.sin(deltaLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

function degreesToRadians(degrees) {
  return (degrees * Math.PI) / 180;
}
