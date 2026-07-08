import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

const repoRoot = path.resolve(process.cwd(), "..");
const serviceAccountPath =
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
  process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!serviceAccountPath) {
  console.error("Missing FIREBASE_SERVICE_ACCOUNT_PATH.");
  process.exit(1);
}

const catalogPath = path.join(
  repoRoot,
  "assets",
  "data",
  "wallpapers_sample.json",
);
const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
const serviceAccount = JSON.parse(
  fs.readFileSync(path.resolve(serviceAccountPath), "utf8"),
);
const bucketName =
  process.env.FIREBASE_STORAGE_BUCKET ||
  `${serviceAccount.project_id}.firebasestorage.app`;

if (getApps().length === 0) {
  initializeApp({
    credential: cert(serviceAccount),
    storageBucket: bucketName,
  });
}

const db = getFirestore();
const bucket = getStorage().bucket();
const batch = db.batch();

for (const wallpaper of catalog.wallpapers) {
  const fullLocalPath = path.join(repoRoot, wallpaper.localAssetPath);
  const thumbLocalPath = path.join(repoRoot, wallpaper.thumbnailAssetPath);
  const fullStoragePath = `wallpapers/full/${path.basename(fullLocalPath)}`;
  const thumbStoragePath = `wallpapers/thumbs/${path.basename(thumbLocalPath)}`;

  await uploadFile(fullLocalPath, fullStoragePath);
  await uploadFile(thumbLocalPath, thumbStoragePath);

  const docRef = db.collection("wallpaper_catalog").doc(wallpaper.id);
  batch.set(docRef, {
    ...wallpaper,
    storagePath: fullStoragePath,
    thumbnailStoragePath: thumbStoragePath,
    source: "firebase-storage",
    updatedAt: new Date().toISOString(),
  });
}

batch.set(db.collection("wallpaper_catalog_metadata").doc("current"), {
  categories: catalog.categories,
  count: catalog.wallpapers.length,
  updatedAt: new Date().toISOString(),
});

await batch.commit();
console.log(
  `Uploaded ${catalog.wallpapers.length} wallpapers to ${bucketName} and Firestore metadata.`,
);

async function uploadFile(localPath, storagePath) {
  try {
    await bucket.upload(localPath, {
      destination: storagePath,
      metadata: {
        contentType: "image/jpeg",
        cacheControl: "public, max-age=31536000",
      },
    });
  } catch (error) {
    if (error?.code === 404 || error?.status === 404) {
      console.error(
        `Firebase Storage bucket bulunamadı: ${bucketName}\n` +
          "Firebase Console > Build > Storage bölümünden bucket oluşturun, " +
          "sonra npm run upload:wallpapers komutunu tekrar çalıştırın.",
      );
      process.exit(1);
    }
    throw error;
  }
}
