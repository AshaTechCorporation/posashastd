import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceInfoChannel = FlutterMethodChannel(name: "device_info",
                                                binaryMessenger: controller.binaryMessenger)

    deviceInfoChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      switch call.method {
      case "getVendorId":
        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
          result(vendorId)
        } else {
          result(FlutterError(code: "UNAVAILABLE",
                            message: "Vendor ID not available",
                            details: nil))
        }
      case "getMacAddress":
        // สำหรับ iOS ใช้ WiFi MAC Address (ถ้าได้) หรือ identifierForVendor
        if let macAddress = self.getMacAddress() {
          result(macAddress)
        } else {
          result(FlutterError(code: "UNAVAILABLE",
                            message: "MAC Address not available",
                            details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getMacAddress() -> String? {
    // สำหรับ iOS เนื่องจากไม่สามารถดึง MAC Address ได้โดยตรง
    // ใช้ identifierForVendor แทน และแปลงเป็นรูปแบบ MAC Address
    if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
      // เอาแค่ 12 ตัวแรกและใส่ : ทุก 2 ตัว
      let cleanId = vendorId.replacingOccurrences(of: "-", with: "").uppercased()
      let macLike = String(cleanId.prefix(12))
      var result = ""
      for i in stride(from: 0, to: macLike.count, by: 2) {
        let start = macLike.index(macLike.startIndex, offsetBy: i)
        let end = macLike.index(start, offsetBy: min(2, macLike.count - i))
        result += String(macLike[start..<end])
        if i < macLike.count - 2 {
          result += ":"
        }
      }
      return result
    }

    // ถ้าไม่ได้ identifierForVendor ให้ใช้ device info อื่น
    let deviceName = UIDevice.current.name
    let deviceModel = UIDevice.current.model
    let combined = "\(deviceName)-\(deviceModel)"

    // แปลงเป็น hash และสร้างเป็นรูปแบบ MAC Address
    let hash = combined.hash
    let hashString = String(abs(hash))
    let macLike = String(hashString.prefix(12)).padding(toLength: 12, withPad: "0", startingAt: 0)

    var result = ""
    for i in stride(from: 0, to: macLike.count, by: 2) {
      let start = macLike.index(macLike.startIndex, offsetBy: i)
      let end = macLike.index(start, offsetBy: min(2, macLike.count - i))
      result += String(macLike[start..<end])
      if i < macLike.count - 2 {
        result += ":"
      }
    }
    return result.uppercased()
  }
}
