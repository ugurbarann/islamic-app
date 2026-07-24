import AppTrackingTransparency
import FBSDKCoreKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let trackingPromptDelay: TimeInterval = 8

  private var trackingAuthorizationRequestScheduled = false
  private var didBecomeActiveObserver: NSObjectProtocol?

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
