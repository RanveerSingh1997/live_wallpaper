import Flutter
import UIKit
import Photos
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var wallpaperChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LiveWallpaperPlugin") {
      let channel = FlutterMethodChannel(
        name: "com.example.live_wallpaper/wallpaper",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { [weak self] (call, result) in
        self?.handleMethodCall(call: call, result: result)
      }
      self.wallpaperChannel = channel
    }
  }

  private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setLiveWallpaper":
      guard let args = call.arguments as? [String: Any],
            let videoPath = args["videoPath"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing videoPath argument", details: nil))
        return
      }
      let imagePath = args["imagePath"] as? String
      self.applyWallpaperOnIOS(videoPath: videoPath, imagePath: imagePath, result: result)

    case "shareWallpaper", "shareVideo":
      guard let args = call.arguments as? [String: Any],
            let videoPath = args["videoPath"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing videoPath argument", details: nil))
        return
      }
      let imagePath = args["imagePath"] as? String
      self.presentWallpaperShareSheet(videoPath: videoPath, imagePath: imagePath, result: result)

    case "openPhotos":
      if let url = URL(string: "photos-redirect://"), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        result(true)
      } else {
        result(false)
      }

    case "isWallpaperActive":
      result(false)

    case "setAudioMuted":
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Applies the wallpaper on iPadOS / iOS:
  /// 1. Extracts high-res wallpaper image (so iPadOS 'Use as Wallpaper' is supported).
  /// 2. Saves the image and video loop to Photos with proper addOnly authorization.
  /// 3. Presents the native iPad Share Sheet with the UIImage, enabling the system "Use as Wallpaper" action.
  private func applyWallpaperOnIOS(videoPath: String, imagePath: String?, result: @escaping FlutterResult) {
    let videoUrl = URL(fileURLWithPath: videoPath)

    // 1. Obtain high-resolution wallpaper image
    let wallpaperImage: UIImage? = {
      if let imagePath = imagePath, FileManager.default.fileExists(atPath: imagePath) {
        return UIImage(contentsOfFile: imagePath)
      }
      return self.extractHighResFrame(from: videoUrl)
    }()

    // 2. Check Photo Library Permission with iOS 14+ addOnly scope
    self.checkPhotoLibraryPermission { [weak self] granted, errorMessage in
      guard let self = self else { return }
      guard granted else {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "PERMISSION_DENIED",
            message: errorMessage ?? "Photo Library access was not granted.",
            details: nil
          ))
        }
        return
      }

      // 3. Save both Image (for iPad Wallpaper) and Video to Photos
      PHPhotoLibrary.shared().performChanges({
        if let image = wallpaperImage {
          PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
      }) { success, error in
        DispatchQueue.main.async {
          if success {
            // Present native iPad share sheet with UIImage so "Use as Wallpaper" is immediately shown
            if let image = wallpaperImage, let topVC = self.getTopViewController() {
              self.showActivityViewController(with: [image], from: topVC)
            }

            result([
              "status": "saved_to_photos",
              "isAlreadyActive": false,
              "message": "Saved to Photos! Select 'Use as Wallpaper' from the share sheet to apply to Lock & Home Screen."
            ])
          } else {
            result(FlutterError(
              code: "SAVE_FAILED",
              message: error?.localizedDescription ?? "Could not save wallpaper to Photos.",
              details: nil
            ))
          }
        }
      }
    }
  }

  /// Presents the system Share Sheet anchored properly for iPad.
  private func presentWallpaperShareSheet(videoPath: String, imagePath: String?, result: @escaping FlutterResult) {
    let videoUrl = URL(fileURLWithPath: videoPath)
    let wallpaperImage: UIImage? = {
      if let imagePath = imagePath, FileManager.default.fileExists(atPath: imagePath) {
        return UIImage(contentsOfFile: imagePath)
      }
      return self.extractHighResFrame(from: videoUrl)
    }()

    DispatchQueue.main.async {
      guard let topVC = self.getTopViewController() else {
        result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Cannot find root view controller", details: nil))
        return
      }

      // Passing UIImage triggers the native iPadOS "Use as Wallpaper" action
      var items: [Any] = []
      if let image = wallpaperImage {
        items.append(image)
      } else {
        items.append(videoUrl)
      }

      self.showActivityViewController(with: items, from: topVC)
      result(true)
    }
  }

  private func showActivityViewController(with items: [Any], from viewController: UIViewController) {
    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)

    // Critical for iPad: Anchor popover to prevent crash
    if let popover = activityViewController.popoverPresentationController {
      popover.sourceView = viewController.view
      popover.sourceRect = CGRect(
        x: viewController.view.bounds.midX,
        y: viewController.view.bounds.midY,
        width: 1,
        height: 1
      )
      popover.permittedArrowDirections = []
    }

    viewController.present(activityViewController, animated: true, completion: nil)
  }

  /// Extracts a crisp full-resolution frame from the video asset.
  private func extractHighResFrame(from videoUrl: URL) -> UIImage? {
    let asset = AVAsset(url: videoUrl)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: 3840, height: 3840) // Full Retina/4K
    do {
      let time = CMTime(seconds: 0.1, preferredTimescale: 600)
      let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
      return UIImage(cgImage: cgImage)
    } catch {
      print("LiveWallpaper: Failed to extract video frame: \(error)")
      return nil
    }
  }

  /// Validates Photo Library permission using addOnly for iOS 14+.
  private func checkPhotoLibraryPermission(completion: @escaping (Bool, String?) -> Void) {
    if #available(iOS 14, *) {
      let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      switch status {
      case .authorized, .limited:
        completion(true, nil)
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
          DispatchQueue.main.async {
            if newStatus == .authorized || newStatus == .limited {
              completion(true, nil)
            } else {
              completion(false, "Photo Library access was not granted.")
            }
          }
        }
      case .denied, .restricted:
        completion(false, "Photo Library access is denied. Please allow 'Add Photos Only' in iPad Settings > Live Wallpaper.")
      @unknown default:
        completion(false, "Unknown Photo Library authorization status.")
      }
    } else {
      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .authorized:
        completion(true, nil)
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization { newStatus in
          DispatchQueue.main.async {
            if newStatus == .authorized {
              completion(true, nil)
            } else {
              completion(false, "Photo Library access was not granted.")
            }
          }
        }
      case .denied, .restricted:
        completion(false, "Photo Library access was denied in Settings.")
      @unknown default:
        completion(false, "Unknown status.")
      }
    }
  }

  /// Finds the currently active top view controller on iPadOS/iOS under SceneDelegate or traditional window.
  private func getTopViewController() -> UIViewController? {
    if #available(iOS 13.0, *) {
      let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      for scene in scenes {
        for window in scene.windows where window.isKeyWindow {
          var topController = window.rootViewController
          while let presented = topController?.presentedViewController {
            topController = presented
          }
          return topController
        }
      }
    }
    var topController = self.window?.rootViewController
    while let presented = topController?.presentedViewController {
      topController = presented
    }
    return topController
  }
}
