import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let settingsChannel = FlutterMethodChannel(
        name: "smart_alarm/settings",
        binaryMessenger: controller.binaryMessenger
      )

      settingsChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "openAppSettings":
          guard let url = URL(string: UIApplication.openSettingsURLString) else {
            result(false)
            return
          }

          UIApplication.shared.open(url) { success in
            result(success)
          }
        case "getLocalTimezone":
          result(TimeZone.current.identifier)
        default:
          result(FlutterMethodNotImplemented)
          return
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
