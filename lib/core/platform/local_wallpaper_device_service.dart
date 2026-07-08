import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'wallpaper_device_service.dart';

class LocalWallpaperDeviceService implements WallpaperDeviceService {
  const LocalWallpaperDeviceService();

  static const MethodChannel _channel = MethodChannel(
    'com.islamicep.app/wallpaper',
  );

  @override
  Future<WallpaperDeviceActionResult> saveToAppStorage({
    required String assetPath,
    required String fileName,
  }) async {
    if (Platform.isAndroid) {
      try {
        final savedUri = await _channel.invokeMethod<String>('saveToGallery', {
          'assetPath': assetPath,
          'title': fileName,
        });
        return WallpaperDeviceActionResult(
          success: true,
          message: 'Duvar kağıdı galeriye kaydedildi.',
          savedPath: savedUri,
        );
      } on PlatformException catch (error) {
        return WallpaperDeviceActionResult(
          success: false,
          message: error.message ?? 'Duvar kağıdı galeriye kaydedilemedi.',
        );
      }
    }

    final bytes = await rootBundle.load(assetPath);
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final wallpaperDirectory = Directory(
      path.join(documentsDirectory.path, 'wallpapers'),
    );
    if (!await wallpaperDirectory.exists()) {
      await wallpaperDirectory.create(recursive: true);
    }

    final extension = path.extension(assetPath).isEmpty
        ? '.jpg'
        : path.extension(assetPath);
    final safeFileName = _safeFileName(fileName);
    final outputFile = File(
      path.join(wallpaperDirectory.path, '$safeFileName$extension'),
    );
    await outputFile.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    return WallpaperDeviceActionResult(
      success: true,
      message: 'Duvar kağıdı cihaza kaydedildi.',
      savedPath: outputFile.path,
    );
  }

  @override
  Future<WallpaperDeviceActionResult> shareWallpaper({
    required String assetPath,
    required String title,
  }) async {
    if (!Platform.isAndroid) {
      return const WallpaperDeviceActionResult(
        success: false,
        message: 'Paylaşma bu cihazda desteklenmiyor.',
      );
    }

    try {
      await _channel.invokeMethod<bool>('share', {
        'assetPath': assetPath,
        'title': title,
      });
      return const WallpaperDeviceActionResult(
        success: true,
        message: 'Paylaşım ekranı açıldı.',
      );
    } on PlatformException catch (error) {
      return WallpaperDeviceActionResult(
        success: false,
        message: error.message ?? 'Paylaşım ekranı açılamadı.',
      );
    }
  }

  @override
  Future<WallpaperDeviceActionResult> setAsWallpaper({
    required String assetPath,
    required String title,
    required WallpaperTarget target,
  }) async {
    if (!Platform.isAndroid) {
      return const WallpaperDeviceActionResult(
        success: false,
        message: 'Duvar kağıdı yapma bu cihazda desteklenmiyor.',
      );
    }

    try {
      await _channel.invokeMethod<bool>('setAsWallpaper', {
        'assetPath': assetPath,
        'title': title,
        'target': target.platformValue,
      });
      return WallpaperDeviceActionResult(
        success: true,
        message: target.successMessage,
      );
    } on PlatformException catch (error) {
      return WallpaperDeviceActionResult(
        success: false,
        message: error.message ?? 'Duvar kağıdı uygulanamadı.',
      );
    }
  }

  String _safeFileName(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ğüşıöç]+', caseSensitive: false), '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
