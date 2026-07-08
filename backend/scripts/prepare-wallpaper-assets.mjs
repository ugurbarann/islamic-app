import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import sharp from "sharp";

const repoRoot = path.resolve(process.cwd(), "..");
const generatedDir =
  process.argv[2] ||
  path.join(
    process.env.USERPROFILE || "",
    ".codex",
    "generated_images",
    "019ee613-ccd7-7dd1-b9b2-393333e46089",
  );

const wallpaperDir = path.join(repoRoot, "assets", "wallpapers");
const thumbnailDir = path.join(wallpaperDir, "thumbs");

const catalog = [
  ["wp_serene_white_mosque", "Önerilen", "recommended", "serene_white_mosque"],
  ["wp_kaaba_blue_hour", "Kâbe Mavi Saat", "kaaba", "kaaba_blue_hour"],
  ["wp_medina_courtyard", "Medine Avlusu", "masjid", "medina_courtyard"],
  ["wp_ottoman_tiles", "Osmanlı Mavisi", "masjid", "ottoman_tiles"],
  [
    "wp_mountain_lake_mosque",
    "Dağ Gölü Mescidi",
    "nature",
    "mountain_lake_mosque",
  ],
  [
    "wp_white_arch_calligraphy",
    "Beyaz Hat Nişi",
    "calligraphy",
    "white_arch_calligraphy",
  ],
  ["wp_desert_crescent", "Çöl Hilali", "nature", "desert_crescent"],
  ["wp_modern_reflection", "Modern Mescid", "masjid", "modern_reflection"],
  ["wp_kaaba_dawn", "Kâbe Şafak", "kaaba", "kaaba_dawn"],
  ["wp_moonlit_mosque", "Hilalli Gece", "masjid", "moonlit_mosque"],
  ["wp_arch_minaret", "Minareli Kemer", "masjid", "arch_minaret"],
  ["wp_quran_beads", "Sessiz Sabah", "recommended", "quran_beads"],
  [
    "wp_turquoise_dome_rain",
    "Yağmur Sonrası Kubbe",
    "masjid",
    "turquoise_dome_rain",
  ],
  ["wp_prayer_rug_dawn", "Seccade ve Şafak", "recommended", "prayer_rug_dawn"],
  ["wp_fog_mosque", "Sisli Mescid", "masjid", "fog_mosque"],
  ["wp_coastal_mosque", "Sahil Mescidi", "nature", "coastal_mosque"],
  ["wp_mihrab_lanterns", "Mihrab Işığı", "calligraphy", "mihrab_lanterns"],
  ["wp_winter_mosque", "Kış Sessizliği", "nature", "winter_mosque"],
  ["wp_garden_path_mosque", "Bahçe Yolu", "nature", "garden_path_mosque"],
  ["wp_geometric_ceiling", "Mavi Geometri", "calligraphy", "geometric_ceiling"],
];

const categoryTitles = new Map([
  ["recommended", "Önerilen"],
  ["masjid", "Mescid"],
  ["kaaba", "Kâbe"],
  ["nature", "Doğa"],
  ["calligraphy", "Hat"],
]);

const sources = fs
  .readdirSync(generatedDir)
  .filter((fileName) => /\.(png|jpe?g|webp)$/i.test(fileName))
  .map((fileName) => path.join(generatedDir, fileName))
  .sort((first, second) => {
    return fs.statSync(first).mtimeMs - fs.statSync(second).mtimeMs;
  });

if (sources.length < catalog.length) {
  throw new Error(
    `Expected at least ${catalog.length} generated images, found ${sources.length}`,
  );
}

fs.mkdirSync(wallpaperDir, { recursive: true });
fs.mkdirSync(thumbnailDir, { recursive: true });

for (const fileName of fs.readdirSync(wallpaperDir)) {
  const target = path.join(wallpaperDir, fileName);
  if (fs.statSync(target).isFile()) {
    fs.unlinkSync(target);
  }
}
for (const fileName of fs.readdirSync(thumbnailDir)) {
  fs.unlinkSync(path.join(thumbnailDir, fileName));
}

const wallpapers = [];
for (let index = 0; index < catalog.length; index += 1) {
  const [id, title, categoryId, slug] = catalog[index];
  const source = sources[index];
  const imageName = `${slug}.jpg`;
  const fullPath = path.join(wallpaperDir, imageName);
  const thumbPath = path.join(thumbnailDir, imageName);

  await sharp(source)
    .resize({ width: 1080, height: 1920, fit: "cover", position: "attention" })
    .jpeg({ quality: 78, mozjpeg: true })
    .toFile(fullPath);

  await sharp(source)
    .resize({ width: 360, height: 640, fit: "cover", position: "attention" })
    .jpeg({ quality: 66, mozjpeg: true })
    .toFile(thumbPath);

  const colorHex = await averageColorHex(thumbPath);
  wallpapers.push({
    id,
    categoryId,
    title,
    localAssetPath: `assets/wallpapers/${imageName}`,
    thumbnailAssetPath: `assets/wallpapers/thumbs/${imageName}`,
    colorHex,
  });
}

const outputCatalog = {
  categories: [...categoryTitles.entries()].map(([id, title]) => ({
    id,
    title,
  })),
  wallpapers,
};

fs.writeFileSync(
  path.join(repoRoot, "assets", "data", "wallpapers_sample.json"),
  `${JSON.stringify(outputCatalog, null, 2)}\n`,
  "utf8",
);

const fullSize = sizeOf(wallpaperDir);
const thumbSize = sizeOf(thumbnailDir);
console.log(`Prepared ${wallpapers.length} wallpapers.`);
console.log(`Full images: ${Math.round(fullSize / 1024)} KB`);
console.log(`Thumbnails: ${Math.round(thumbSize / 1024)} KB`);

async function averageColorHex(imagePath) {
  const stats = await sharp(imagePath).resize(1, 1).raw().toBuffer();
  return [...stats]
    .slice(0, 3)
    .map((value) => value.toString(16).padStart(2, "0"))
    .join("")
    .toUpperCase();
}

function sizeOf(directory) {
  return fs.readdirSync(directory).reduce((total, fileName) => {
    const target = path.join(directory, fileName);
    const stat = fs.statSync(target);
    return total + (stat.isFile() ? stat.size : 0);
  }, 0);
}
