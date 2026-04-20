import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let settingsChannel = FlutterMethodChannel(
        name: "smart_alarm/settings",
        binaryMessenger: controller.engine.binaryMessenger
      )

      settingsChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "openAppSettings":
          guard
            let url = URL(
              string: "x-apple.systempreferences:com.apple.preference.notifications"
            )
          else {
            result(false)
            return
          }
          NSWorkspace.shared.open(url)
          result(true)
        case "getLocalTimezone":
          result(TimeZone.current.identifier)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
