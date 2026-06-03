import FirebaseCore
import FirebaseMessaging
import Flutter
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase natively before APNs registration so the Messaging
    // SDK is ready to receive the device token (Dart's Firebase.initializeApp
    // reuses this same default app). Fixes the startup
    // "[FirebaseCore] No app has been configured yet." warning.
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    GMSServices.provideAPIKey("AIzaSyDVjB-dVk0Fy325gPWUaJGAbatgTSLD-PU")

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // Register for APNS immediately so FCM can obtain a token on cold start.
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "com.yaqeen.mobile/push",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "registerForRemoteNotifications" else {
        result(FlutterMethodNotImplemented)
        return
      }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
      result(nil)
    }
  }

  // Remote FCM/APNs push: Dart re-posts a local notification with the custom chime,
  // so suppress the system banner here to avoid showing the notification twice.
  // Local notifications (from flutter_local_notifications): show them normally.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let triggerType = notification.request.trigger.map { String(describing: type(of: $0)) } ?? "nil"
    NSLog("[FCM] willPresent — trigger: %@, id: %@", triggerType, notification.request.identifier)

    if notification.request.trigger is UNPushNotificationTrigger {
      NSLog("[FCM] willPresent — suppressing remote push (Dart will show local instead)")
      completionHandler([])
    } else {
      NSLog("[FCM] willPresent — showing local notification")
      completionHandler([.banner, .sound, .badge])
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)

    // Explicitly tell FCM which APNs environment this token belongs to.
    // Swizzling alone registers it as `.unknown`, and the FCM backend then
    // defaults to the PRODUCTION APNs gateway — which silently drops the
    // SANDBOX token a development build receives. That mismatch is why pushes
    // worked on Android but never arrived on iOS.
    //
    // We detect the environment at runtime from the embedded provisioning
    // profile rather than `#if DEBUG`, because the Runner target's Debug config
    // does not define the DEBUG Swift flag (so `#if DEBUG` wrongly chose .prod).
    let tokenType = detectAPNSTokenType()
    Messaging.messaging().setAPNSToken(deviceToken, type: tokenType)
    NSLog("[FCM] APNS token type set to %@", tokenType == .sandbox ? "SANDBOX" : "PROD")

    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    NSLog("[FCM] APNS device token registered: \(token.prefix(16))...")
  }

  /// Determines whether this build's APNs token targets the sandbox or
  /// production gateway.
  ///
  /// - Simulator → always `.sandbox`
  /// - Debug build (Xcode / ad-hoc dev) → `.sandbox` via `#if DEBUG`
  ///   (`SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG` is set in Flutter/Debug.xcconfig)
  /// - Release / Profile build → reads `aps-environment` from the embedded
  ///   provisioning profile (TestFlight → `production`; App Store → no profile → `.prod`)
  private func detectAPNSTokenType() -> MessagingAPNSTokenType {
    #if targetEnvironment(simulator)
      return .sandbox
    #elseif DEBUG
      return .sandbox
    #else
      guard
        let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
        let data = try? Data(contentsOf: url),
        let raw = String(data: data, encoding: .isoLatin1),
        let start = raw.range(of: "<?xml"),
        let end = raw.range(of: "</plist>")
      else {
        // No embedded profile → App Store distribution (Apple re-signs)
        return .prod
      }

      // Use ..<end.upperBound (half-open range) to exclude the binary byte
      // that follows </plist> in the CMS-signed provisioning profile blob.
      let plistString = String(raw[start.lowerBound..<end.upperBound])
      guard
        let plistData = plistString.data(using: .isoLatin1),
        let plist = try? PropertyListSerialization.propertyList(
          from: plistData, options: [], format: nil) as? [String: Any],
        let entitlements = plist["Entitlements"] as? [String: Any],
        let apsEnvironment = entitlements["aps-environment"] as? String
      else {
        return .prod
      }

      return apsEnvironment == "development" ? .sandbox : .prod
    #endif
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    NSLog("[FCM] APNS registration failed: \(error.localizedDescription)")
  }
}
