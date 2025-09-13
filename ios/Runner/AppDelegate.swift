import Flutter
import UIKit
import Intents

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    donateCreateNoteIntent()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func donateCreateNoteIntent() {
    let activity = NSUserActivity(activityType: "CreateNoteIntent")
    activity.title = "Create Note"
    activity.isEligibleForPrediction = true
    activity.persistentIdentifier = NSUserActivityPersistentIdentifier("CreateNoteIntent")
    activity.suggestedInvocationPhrase = "Create note"
    activity.becomeCurrent()
  }

  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == "CreateNoteIntent" {
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "pandora/actions", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("voiceToNote", arguments: nil)
      }
      return true
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
