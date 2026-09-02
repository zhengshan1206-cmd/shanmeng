import Flutter
import UIKit
import BDASignalSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.by.ve.bridge"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    BDASignalManager.register(withOptionalData: nil)
    BDASignalManager.didFinishLaunching(options: launchOptions, connect: nil)
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handleBridgeCall(call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    BDASignalManager.anylyseDeeplinkClickid(withOpenUrl: url.absoluteString)
    return super.application(app, open: url, options: options)
  }

  private func handleBridgeCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "appInit":
      result(baseResult(code: 200))
    case "oceanengineEvent":
      guard
        let args = call.arguments as? [String: Any],
        let params = args["params"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "missing params", details: nil))
        return
      }
      handleOceanengineEvent(params)
      result(baseResult(code: 200))
    case "appDeviceInfo":
      result(baseResult(code: 200, data: ["oId": "", "androidId": ""]))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleOceanengineEvent(_ eventString: String) {
    guard
      let data = eventString.data(using: .utf8),
      var event = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
      let eventName = event["event"] as? String
    else {
      return
    }

    event.removeValue(forKey: "_auto_id_")
    switch eventName {
    case "register":
      BDASignalManager.trackEssentialEvent(withName: kBDADSignalSDKEventRegister, params: nil)
    case "purchase":
      let money = (event["money"] as? NSNumber)?.doubleValue ?? 0
      let payAmount = Int(money * 100)
      BDASignalManager.trackEssentialEvent(
        withName: kBDADSignalSDKEventPurchase,
        params: ["pay_amount": payAmount]
      )
    case "game_addiction":
      var params: [AnyHashable: Any] = [:]
      if let originEvent = event["origin_event"] {
        params["origin_event"] = originEvent
      }
      BDASignalManager.trackEssentialEvent(withName: kBDADSignalSDKEventGameAddiction, params: params)
    default:
      event.removeValue(forKey: "event")
      BDASignalManager.trackEssentialEvent(withName: eventName, params: event)
    }
  }

  private func baseResult(code: Int, data: [String: Any]? = nil) -> [String: Any] {
    if let data {
      return ["code": code, "data": data]
    }
    return ["code": code]
  }
}
