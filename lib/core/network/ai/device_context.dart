// 采集设备与应用环境信息。
// 网络层、登录态初始化和部分接口请求都依赖这里提供的设备上下文。
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 运行设备的静态上下文。
class DeviceContext {
  DeviceContext({
    required this.uuid,
    required this.appVersion,
    required this.userAgent,
    required this.platformName,
    required this.languageCode,
    required this.countryCode,
  });

  final String uuid;
  final String appVersion;
  final String userAgent;
  final String platformName;
  final String languageCode;
  final String countryCode;

  /// 从平台能力中读取设备标识、版本、语言等请求参数。
  static Future<DeviceContext> create() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final locale = PlatformDispatcher.instance.locale;
    final deviceInfo = DeviceInfoPlugin();
    final uuid = await _resolveUuid(deviceInfo);
    final platformName = _platformName();

    return DeviceContext(
      uuid: uuid,
      appVersion: packageInfo.version,
      userAgent: 'Lingbao/${packageInfo.version} ($platformName; Flutter)',
      platformName: platformName,
      languageCode: locale.languageCode,
      countryCode: locale.countryCode ?? '',
    );
  }

  static Future<String> _resolveUuid(DeviceInfoPlugin deviceInfo) async {
    if (kIsWeb) {
      final web = await deviceInfo.webBrowserInfo;
      return web.userAgent ?? 'web-browser';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = await deviceInfo.androidInfo;
        return android.id;
      case TargetPlatform.iOS:
        final ios = await deviceInfo.iosInfo;
        return ios.identifierForVendor ?? 'ios-simulator';
      case TargetPlatform.macOS:
        final mac = await deviceInfo.macOsInfo;
        return mac.systemGUID ?? mac.model;
      case TargetPlatform.windows:
        final windows = await deviceInfo.windowsInfo;
        return windows.deviceId;
      case TargetPlatform.linux:
        await deviceInfo.linuxInfo;
        return 'linux-device';
      case TargetPlatform.fuchsia:
        return 'fuchsia-device';
    }
  }

  static String _platformName() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
