import AppTrackingTransparency
import FBSDKCoreKit
import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let trackingPromptDelay: TimeInterval = 8
  private static let wallpaperChannelName = "com.islamicep.app/wallpaper"

  private var trackingAuthorizationRequestScheduled = false
  private var didBecomeActiveObserver: NSObjectProtocol?
  private var wallpaperChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    Settings.shared.isAutoLogAppEventsEnabled = true
    syncMetaAdvertiserTrackingStatus()
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    observeApplicationActivation()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    wallpaperChannel = FlutterMethodChannel(
      name: Self.wallpaperChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    wallpaperChannel?.setMethodCallHandler { [weak self] call, result in
      guard call.method == "saveToPhotos" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let arguments = call.arguments as? [String: Any],
            let assetPath = arguments["assetPath"] as? String,
            !assetPath.isEmpty
      else {
        result(
          FlutterError(
            code: "missing_asset",
            message: "Görsel yolu bulunamadı.",
            details: nil
          )
        )
        return
      }
      guard let self else {
        result(
          FlutterError(
            code: "wallpaper_action_failed",
            message: "Fotoğraflara kaydetme işlemi başlatılamadı.",
            details: nil
          )
        )
        return
      }
      self.saveWallpaperToPhotos(assetPath: assetPath, result: result)
    }
  }

  private func saveWallpaperToPhotos(
    assetPath: String,
    result: @escaping FlutterResult
  ) {
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
      guard let self else {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "wallpaper_action_failed",
              message: "Fotoğraflara kaydetme işlemi tamamlanamadı.",
              details: nil
            )
          )
        }
        return
      }

      switch status {
      case .authorized, .limited:
        self.persistWallpaperAsset(assetPath: assetPath, result: result)
      case .denied, .restricted:
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "photo_permission_denied",
              message:
                "Fotoğraflara ekleme izni verilmedi. iPhone Ayarları'ndan "
                + "İslami Cep için Fotoğraflar iznini açabilirsiniz.",
              details: nil
            )
          )
        }
      case .notDetermined:
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "photo_permission_unavailable",
              message: "Fotoğraflar izni henüz belirlenemedi.",
              details: nil
            )
          )
        }
      @unknown default:
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "photo_permission_unavailable",
              message: "Fotoğraflar izni kontrol edilemedi.",
              details: nil
            )
          )
        }
      }
    }
  }

  private func persistWallpaperAsset(
    assetPath: String,
    result: @escaping FlutterResult
  ) {
    let assetKey = FlutterDartProject.lookupKey(forAsset: assetPath)
    guard let assetURL = Bundle.main.url(
      forResource: assetKey,
      withExtension: nil
    ) else {
      DispatchQueue.main.async {
        result(
          FlutterError(
            code: "asset_not_found",
            message: "Kaydedilecek duvar kağıdı bulunamadı.",
            details: nil
          )
        )
      }
      return
    }

    var localIdentifier: String?
    PHPhotoLibrary.shared().performChanges {
      let request = PHAssetCreationRequest.forAsset()
      request.addResource(with: .photo, fileURL: assetURL, options: nil)
      localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
    } completionHandler: { success, error in
      DispatchQueue.main.async {
        if success {
          result(localIdentifier)
        } else {
          result(
            FlutterError(
              code: "photo_save_failed",
              message:
                error?.localizedDescription
                ?? "Duvar kağıdı Fotoğraflar'a kaydedilemedi.",
              details: nil
            )
          )
        }
      }
    }
  }

  private func observeApplicationActivation() {
    didBecomeActiveObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.scheduleTrackingAuthorizationRequestIfNeeded()
    }
  }

  private func scheduleTrackingAuthorizationRequestIfNeeded() {
    guard #available(iOS 14, *),
          ATTrackingManager.trackingAuthorizationStatus == .notDetermined,
          !trackingAuthorizationRequestScheduled
    else {
      syncMetaAdvertiserTrackingStatus()
      return
    }

    trackingAuthorizationRequestScheduled = true
    DispatchQueue.main.asyncAfter(deadline: .now() + Self.trackingPromptDelay) { [weak self] in
      self?.trackingAuthorizationRequestScheduled = false
      self?.requestTrackingAuthorizationIfNeeded()
    }
  }

  private func requestTrackingAuthorizationIfNeeded() {
    guard #available(iOS 14, *),
          UIApplication.shared.applicationState == .active,
          ATTrackingManager.trackingAuthorizationStatus == .notDetermined
    else {
      syncMetaAdvertiserTrackingStatus()
      return
    }

    ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
      DispatchQueue.main.async {
        self?.syncMetaAdvertiserTrackingStatus()
      }
    }
  }

  private func syncMetaAdvertiserTrackingStatus() {
    guard #available(iOS 14, *) else {
      return
    }

    // Facebook iOS SDK 17+ reads ATT directly on iOS 17 and later.
    if #available(iOS 17, *) {
      return
    }

    Settings.shared.isAdvertiserTrackingEnabled =
      ATTrackingManager.trackingAuthorizationStatus == .authorized
  }
}
