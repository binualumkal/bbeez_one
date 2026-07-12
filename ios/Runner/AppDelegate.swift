import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private var privacyView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Use the registrar to ensure the channel is registered correctly with the Flutter engine
    let registrar = self.registrar(forPlugin: "SecurityPlugin")
    if let messenger = registrar?.messenger() {
        let securityChannel = FlutterMethodChannel(name: "com.bbeezdigital.one/security",
                                                  binaryMessenger: messenger)

        securityChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if (call.method == "setSecure") {
            result(nil)
          } else {
            result(FlutterMethodNotImplemented)
          }
        })
    }

    return result
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)

    if privacyView == nil {
        let frame = self.window?.frame ?? UIScreen.main.bounds
        let view = UIView(frame: frame)
        view.backgroundColor = .black

        if let image = UIImage(named: "LaunchImage") {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            imageView.center = view.center
            view.addSubview(imageView)
        }
        privacyView = view
    }

    if let pView = privacyView {
        self.window?.addSubview(pView)
    }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    privacyView?.removeFromSuperview()
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
