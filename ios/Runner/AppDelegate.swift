import UIKit
import Flutter
import LocalAuthentication

@main
@objc class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "jasmine_engine")

    private func setupMethodChannel(
        binaryMessenger: FlutterBinaryMessenger,
        documentDirectory: String
    ) {
        FlutterMethodChannel(name: "methods", binaryMessenger: binaryMessenger).setMethodCallHandler { (call, result) in
            Thread {
                switch (call.method){
                case "invoke":
                    if let params = call.arguments as? String{
                        let chars = params.cString(using: String.Encoding.utf8)
                        let rsp = invoke_ffi(chars!)
                        let response = String.init(utf8String: rsp!)
                        free_str_ffi(rsp)
                        result(response)
                    }
                    break
                case "saveImageFileToGallery":
                    if let path = call.arguments as? String{
                        do {
                            let fileURL: URL = URL(fileURLWithPath: path)
                            let imageData = try Data(contentsOf: fileURL)
                            if let uiImage = UIImage(data: imageData) {
                                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                                result("OK")
                            }else{
                                result(FlutterError(code: "", message: "Error loading image ", details: ""))
                            }
                        } catch {
                            result(FlutterError(code: "", message: "Error loading image : \(error)", details: ""))
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                case "iosGetDocumentDir" :
                    result(documentDirectory)
                case "verifyAuthentication":
                    let context = LAContext()
                    let can = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
                    guard can == true else {
                        result(false)
                        return
                    }
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "身份验证") { (success, error) in
                        result(success)
                    }
                default:
                    result(FlutterMethodNotImplemented)
                }
            }.start()
        }
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fromChars = documentDirectory.cString(using: String.Encoding.utf8)

        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
        let chars = applicationSupportDirectory.cString(using: String.Encoding.utf8)

        migration_ffi(fromChars,chars)
        init_ffi(chars!)

        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)
        setupMethodChannel(binaryMessenger: flutterEngine.binaryMessenger, documentDirectory: documentDirectory)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
