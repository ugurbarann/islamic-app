import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

const seedPath = process.argv[2];
if (!seedPath) {
  console.error(
    "Usage: node scripts/upload-daily-content.mjs seeds/daily_content_YYYY-MM-DD_30_days.json",
  );
  process.exit(1);
}

const serviceAccountPath =
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
  process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!serviceAccountPath) {
  console.error(
    "Missing FIREBASE_SERVICE_ACCOUNT_PATH. Download a Firebase service account key and set its path first.",
  );
  process.exit(1);
}

const absoluteSeedPath = path.resolve(seedPath);
const absoluteServiceAccountPath = path.resolve(serviceAccountPath);
const seed = JSON.parse(fs.readFileSync(absoluteSeedPath, "utf8"));
const serviceAccount = JSON.parse(
  fs.readFileSync(absoluteServiceAccountPath, "utf8"),
);

if (!Array.isArray(seed.bundles) || seed.bundles.length === 0) {
  console.error("Seed file has no bundles.");
  process.exit(1);
}

if (getApps().length === 0) {
  initializeApp({
    credential: cert(serviceAccount),
  });
}

const db = getFirestore();
const collectionName = seed.collection || "daily_content";
let batch = db.batch();
let writesInBatch = 0;
let uploaded = 0;

for (const bundle of seed.bundles) {
  const docRef = db.collection(collectionName).doc(bundle.dateKey);
  batch.set(docRef, bundle, { merge: false });
  writesInBatch += 1;
  uploaded += 1;

  if (writesInBatch === 450) {
    await batch.commit();
    batch = db.batch();
    writesInBatch = 0;
  }
}

if (writesInBatch > 0) {
  await batch.commit();
}

console.log(`Uploaded ${uploaded} documents to ${collectionName}.`);
