import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "..", "..");
const sourcePath = path.join(
  repoRoot,
  "assets",
  "data",
  "daily_content_sample.json",
);
const outputDir = path.join(repoRoot, "backend", "seeds");

const startDateKey = process.argv[2] || "2026-06-21";
const dayCount = Number(process.argv[3] || 30);

const source = JSON.parse(fs.readFileSync(sourcePath, "utf8"));
const bundles = source.bundles.slice(0, dayCount).map((bundle, index) => {
  const dateKey = addDays(startDateKey, index);
  return {
    dateKey,
    metadata: {
      source: "firebase-seed",
      contentVersion: 1,
      lastSyncAt: new Date().toISOString(),
      cachedUntil: addDays(dateKey, 45),
    },
    items: bundle.items.map((item) => normalizeItem(item, dateKey)),
  };
});

const payload = {
  collection: "daily_content",
  generatedAt: new Date().toISOString(),
  startDateKey,
  endDateKey: bundles[bundles.length - 1]?.dateKey,
  count: bundles.length,
  bundles,
};

fs.mkdirSync(outputDir, { recursive: true });
const outputPath = path.join(
  outputDir,
  `daily_content_${startDateKey}_${dayCount}_days.json`,
);
fs.writeFileSync(outputPath, `${JSON.stringify(payload, null, 2)}\n`, "utf8");

console.log(`Generated ${bundles.length} daily content documents.`);
console.log(outputPath);

function normalizeItem(item, dateKey) {
  const normalized = {
    ...item,
    id: `${dateKey}_${item.type}`,
    dateKey,
    validFrom: dateKey,
    validUntil: dateKey,
  };

  if (item.type === "surah_highlight") {
    normalized.id = `${dateKey}_surah`;
  }

  return removeUndefined(normalized);
}

function addDays(dateKey, days) {
  const [year, month, day] = dateKey.split("-").map(Number);
  const date = new Date(Date.UTC(year, month - 1, day + days));
  return date.toISOString().slice(0, 10);
}

function removeUndefined(value) {
  return Object.fromEntries(
    Object.entries(value).filter(([, entryValue]) => entryValue !== undefined),
  );
}
