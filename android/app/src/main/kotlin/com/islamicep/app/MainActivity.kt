package com.islamicep.app

import android.app.WallpaperManager
import android.content.ContentValues
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val wallpaperChannelName = "com.islamicep.app/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            wallpaperChannelName
        ).setMethodCallHandler { call, result ->
            val assetPath = call.argument<String>("assetPath")
            val title = call.argument<String>("title") ?: "İslami Cep Duvar Kağıdı"
            val target = call.argument<String>("target") ?: "home"

            if (assetPath.isNullOrBlank()) {
                result.error("missing_asset", "Görsel yolu bulunamadı.", null)
                return@setMethodCallHandler
            }

            try {
                when (call.method) {
                    "saveToGallery" -> {
                        val savedUri = saveAssetToGallery(assetPath, title)
                        result.success(savedUri.toString())
                    }
                    "share" -> {
                        shareAsset(assetPath, title)
                        result.success(true)
                    }
                    "setAsWallpaper" -> {
                        setAssetAsWallpaper(assetPath, target)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("wallpaper_action_failed", error.localizedMessage, null)
            }
        }
    }

    private fun readFlutterAsset(assetPath: String): ByteArray {
        val assetKey = FlutterInjector
            .instance()
            .flutterLoader()
            .getLookupKeyForAsset(assetPath)
        return assets.open(assetKey).use { input -> input.readBytes() }
    }

    private fun saveAssetToGallery(assetPath: String, title: String): Uri {
        val bytes = readFlutterAsset(assetPath)
        val displayName = "${safeFileName(title)}.jpg"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/İslami Cep")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
            val uri = contentResolver.insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                values
            ) ?: throw IllegalStateException("Galeri kaydı oluşturulamadı.")

            contentResolver.openOutputStream(uri).use { output ->
                output ?: throw IllegalStateException("Galeri dosyası açılamadı.")
                output.write(bytes)
            }

            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)
            return uri
        }

        val pictureDir = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
            "İslami Cep"
        )
        if (!pictureDir.exists()) {
            pictureDir.mkdirs()
        }
        val outputFile = File(pictureDir, displayName)
        FileOutputStream(outputFile).use { output -> output.write(bytes) }
        MediaScannerConnection.scanFile(
            this,
            arrayOf(outputFile.absolutePath),
            arrayOf("image/jpeg"),
            null
        )
        return Uri.fromFile(outputFile)
    }

    private fun shareAsset(assetPath: String, title: String) {
        val bytes = readFlutterAsset(assetPath)
        val cacheDir = File(cacheDir, "wallpapers")
        if (!cacheDir.exists()) {
            cacheDir.mkdirs()
        }
        val outputFile = File(cacheDir, "${safeFileName(title)}.jpg")
        FileOutputStream(outputFile).use { output -> output.write(bytes) }
        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            outputFile
        )
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "image/jpeg"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(intent, "Duvar kağıdını paylaş"))
    }

    private fun setAssetAsWallpaper(assetPath: String, target: String) {
        val bytes = readFlutterAsset(assetPath)
        val bitmap = BitmapFactory.decodeStream(ByteArrayInputStream(bytes))
            ?: throw IllegalStateException("Görsel okunamadı.")
        val wallpaperManager = WallpaperManager.getInstance(this)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            when (target) {
                "lock" -> wallpaperManager.setBitmap(
                    bitmap,
                    null,
                    true,
                    WallpaperManager.FLAG_LOCK
                )
                "both" -> {
                    wallpaperManager.setBitmap(
                        bitmap,
                        null,
                        true,
                        WallpaperManager.FLAG_SYSTEM
                    )
                    wallpaperManager.setBitmap(
                        bitmap,
                        null,
                        true,
                        WallpaperManager.FLAG_LOCK
                    )
                }
                else -> wallpaperManager.setBitmap(
                    bitmap,
                    null,
                    true,
                    WallpaperManager.FLAG_SYSTEM
                )
            }
        } else {
            if (target == "lock") {
                throw IllegalStateException("Kilit ekranı duvar kağıdı bu Android sürümünde desteklenmiyor.")
            }
            wallpaperManager.setBitmap(bitmap)
        }
    }

    private fun safeFileName(value: String): String {
        return value
            .lowercase()
            .replace(Regex("[^a-z0-9ğüşıöç]+"), "_")
            .trim('_')
            .ifBlank { "islami_cep_duvar_kagidi" }
    }
}
