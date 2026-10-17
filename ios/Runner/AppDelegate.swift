import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    if let flutterViewController = controller {
      let wallpaperChannel = FlutterMethodChannel(
        name: "com.example.live_wallpaper/wallpaper",
        binaryMessenger: flutterViewController.binaryMessenger
      )

      wallpaperChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard let self = self else { return }

        switch call.method {
        case "setLiveWallpaper":
          guard let args = call.arguments as? [String: Any],
                let videoPath = args["videoPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing videoPath argument", details: nil))
            return
          }

          self.saveVideoToPhotos(filePath: videoPath) { success, error in
            DispatchQueue.main.async {
              if success {
                result([
                  "status": "saved_to_photos",
                  "isAlreadyActive": false,
                  "message": "Saved to Photos! Open Photos or Settings > Wallpaper to set it on your Lock & Home Screen."
                ])
              } else {
                result(FlutterError(
                  code: "SAVE_FAILED",
                  message: error?.localizedDescription ?? "Could not save video to Photos.",
                  details: nil
                ))
              }
            }
          }

        case "openPhotos":
          if let url = URL(string: "photos-redirect://"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            result(true)
          } else {
            result(false)
          }

        case "shareVideo":
          guard let args = call.arguments as? [String: Any],
                let videoPath = args["videoPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing videoPath", details: nil))
            return
          }
          self.shareVideo(filePath: videoPath, from: flutterViewController)
          result(true)

        case "isWallpaperActive":
          result(false)

        case "setAudioMuted":
          result(true)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func saveVideoToPhotos(filePath: String, completion: @escaping (Bool, Error?) -> Void) {
    let fileUrl = URL(fileURLWithPath: filePath)

    let saveAction = {
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
      }) { success, error in
        completion(success, error)
      }
    }

    let status = PHPhotoLibrary.authorizationStatus()
    if #available(iOS 14, *) {
      if status == .authorized || status == .limited {
        saveAction()
      } else if status == .notDetermined {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
          if newStatus == .authorized || newStatus == .limited {
            saveAction()
          } else {
            completion(false, NSError(
              domain: "LiveWallpaper",
              code: 403,
              userInfo: [NSLocalizedDescriptionKey: "Photo Library access was not granted."]
            ))
          }
        }
      } else {
        completion(false, NSError(
          domain: "LiveWallpaper",
          code: 403,
          userInfo: [NSLocalizedDescriptionKey: "Photo Library access is denied in iPad Settings."]
        ))
      }
    } else {
      if status == .authorized {
        saveAction()
      } else {
        PHPhotoLibrary.requestAuthorization { newStatus in
          if newStatus == .authorized {
            saveAction()
          } else {
            completion(false, NSError(
              domain: "LiveWallpaper",
              code: 403,
              userInfo: [NSLocalizedDescriptionKey: "Photo Library access was denied."]
            ))
          }
        }
      }
    }
  }

  private func shareVideo(filePath: String, from viewController: UIViewController) {
    let fileUrl = URL(fileURLWithPath: filePath)
    let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)

    // Critical for iPad support: Configure popover presentation controller to prevent crash
    if let popover = activityViewController.popoverPresentationController {
      popover.sourceView = viewController.view
      popover.sourceRect = CGRect(
        x: viewController.view.bounds.midX,
        y: viewController.view.bounds.midY,
        width: 0,
        height: 0
      )
      popover.permittedArrowDirections = []
    }

    viewController.present(activityViewController, animated: true, completion: nil)
  }
}
