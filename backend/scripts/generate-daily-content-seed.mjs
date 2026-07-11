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
const duasPath = path.join(repoRoot, "assets", "data", "duas_sample.json");
const knowledgePath = path.join(
  repoRoot,
  "assets",
  "data",
  "islamic_knowledge_sample.json",
);

const startDateKey = process.argv[2] || new Date().toISOString().slice(0, 10);
const dayCount = Number(process.argv[3] || 30);
const updateLocalAsset = process.argv.includes("--update-local");

const source = JSON.parse(fs.readFileSync(sourcePath, "utf8"));
const duaCategories = JSON.parse(fs.readFileSync(duasPath, "utf8"));
const knowledge = JSON.parse(fs.readFileSync(knowledgePath, "utf8"));
const duas = duaCategories.flatMap((category) => category.duas || []);
const knowledgeArticles = (knowledge.categories || []).flatMap(
  (category) => category.articles || [],
);
const bundles = source.bundles.slice(0, dayCount).map((bundle, index) => {
  const dateKey = addDays(startDateKey, index);
  return {
    dateKey,
    metadata: {
      source: "firebase-seed",
      contentVersion: 3,
      lastSyncAt: new Date().toISOString(),
      cachedUntil: addDays(dateKey, 45),
    },
    items: bundle.items.map((item) =>
      normalizeItem(item, dateKey, index),
    ),
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

if (updateLocalAsset) {
  const localPayload = {
    schemaVersion: 1,
    bundles,
    metadata: {
      source: "verified-bundled-content",
      contentVersion: 3,
      cachedUntil: bundles[bundles.length - 1]?.dateKey,
      fallbackMessage:
        "İnternet bağlantısı yok. Cihaza kaydedilmiş günlük içerik gösteriliyor.",
    },
  };
  fs.writeFileSync(sourcePath, `${JSON.stringify(localPayload)}\n`, "utf8");
  console.log(`Updated local fallback: ${sourcePath}`);
}

function normalizeItem(item, dateKey, index) {
  let content = item;
  if (item.type === "dua" && duas.length > 0) {
    const dua = duas[index % duas.length];
    content = {
      ...item,
      title: dua.title,
      turkishText: dua.turkishText,
      arabicText: dua.arabicText,
      turkishTransliteration: dua.turkishTransliteration,
      source: dua.source || "Dua koleksiyonu",
    };
  }
  if (item.type === "knowledge" && knowledgeArticles.length > 0) {
    const article = knowledgeArticles[index % knowledgeArticles.length];
    content = {
      ...item,
      title: article.title,
      turkishText: article.body || article.summary,
      source: "İslami Cep editör içeriği",
      reference: article.summary,
    };
  }

  const normalized = {
    ...content,
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
