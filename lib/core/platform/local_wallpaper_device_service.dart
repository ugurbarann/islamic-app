import 'dart:io';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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

    if (Platform.isIOS) {
      try {
        final savedIdentifier = await _channel.invokeMethod<String>(
          'saveToPhotos',
          {'assetPath': assetPath, 'title': fileName},
        );
        return WallpaperDeviceActionResult(
          success: true,
          message: 'Duvar kağıdı Fotoğraflar’a kaydedildi.',
          savedPath: savedIdentifier,
        );
      } on PlatformException catch (error) {
        return WallpaperDeviceActionResult(
          success: false,
          message: error.message ?? 'Duvar kağıdı Fotoğraflar’a kaydedilemedi.',
        );
      }
    }

    return const WallpaperDeviceActionResult(
      success: false,
      message: 'Fotoğraflara kaydetme bu cihazda desteklenmiyor.',
    );
  }

  @override
  Future<WallpaperDeviceActionResult> shareWallpaper({
    required String assetPath,
    required String title,
  }) async {
    if (!Platform.isAndroid) {
      return _shareAsset(assetPath: assetPath, title: title);
    }

    try {
      await _channel.invokeMethod<bool>('share', {
        'assetPath': assetPath,
        'title': title,
      });
      return const WallpaperDeviceActionResult(success: true, message: '');
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

  Future<WallpaperDeviceActionResult> _shareAsset({
    required String assetPath,
    required String title,
  }) async {
    try {
      final data = await rootBundle.load(assetPath);
      final extension = assetPath.toLowerCase().endsWith('.png')
          ? 'png'
          : 'jpg';
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      final fileName = '${_safeFileName(title)}.$extension';
      final result = await SharePlus.instance.share(
        ShareParams(
          title: title,
          files: [
            XFile.fromData(data.buffer.asUint8List(), mimeType: mimeType),
          ],
          fileNameOverrides: [fileName],
        ),
      );
      if (result.status == ShareResultStatus.unavailable) {
        return const WallpaperDeviceActionResult(
          success: false,
          message: 'Paylaşım ekranı açılamadı.',
        );
      }
      return const WallpaperDeviceActionResult(success: true, message: '');
    } on Object {
      return const WallpaperDeviceActionResult(
        success: false,
        message: 'Duvar kağıdı paylaşım için hazırlanamadı.',
      );
    }
  }
}
