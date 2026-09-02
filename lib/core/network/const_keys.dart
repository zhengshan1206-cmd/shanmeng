/*
 * @Author: cold-x
 * @Date: 2025-06-04 09:23:10
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-20 16:47:48
 * @FilePath: /novel_oversea/lib/core/network/const_keys.dart
 * @Description: 
 */
import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';


///一些静态配置信息
class ConstKeys {
  static const String kToken = "token";  ///用户token
  static const String kClientType = "client_type";  ///客户端类型
  static const String kSign = "sign";  ///客户端签名
  static const String kChannel = "channel";  ///渠道
  static const String kTimeStamp = "timestamp";  ///当前时间戳
  static const String kAccept = "Accept";
  static const String kContentType = "Content-Type";
  static const String kAppVersion = "appVersion";  ///APP版本号
  static const String kAppFramework = "app_framework";
  static const String kUserAgent = "User-Agent";  
  static const String kAcceptLanguage = "Accept-Language";  ///请求语言
  static const String kUserLanguage = "user-language";  ///用户设置语言
  static const String kPosition = "position";  ///定位信息
  static const String kTimeZone = "timezone";  ///用户所在时区
  static const String kIpCountry = "ip_country";  ///用户IP所在国家
  static const String kLocalCountry = "country";  ///用户语言使用国家

  static String userAgentData = "";

  Future<void> initUserAgentData()async{
    userAgentData = await IosUserAgentUtil.getDefaultUserAgent();
    log("userAgentData======> $userAgentData");
  }

}


///苹果用户的 user-agent
class IosUserAgentUtil {
  static String? _defaultUserAgent;

  static Future<String> getDetailedUserAgent() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        /// 获取设备信息
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;

        /// 获取默认User-Agent
        String defaultUserAgent = await getDefaultUserAgent();

        /// 添加设备信息
        return '$defaultUserAgent (${iosInfo.model}; ${iosInfo.systemVersion})';
      } catch (e) {
        return await getDefaultUserAgent();
      }
    }

    return await getDefaultUserAgent();
  }

  static Future<String> getDefaultUserAgent() async {
    if (_defaultUserAgent != null) {
      return _defaultUserAgent!;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted);

        _defaultUserAgent = await controller.getUserAgent();
        return _defaultUserAgent ?? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
      } catch (e) {
        return 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
      }
    }

    return 'Dalvik/2.1.0 (Linux; U; Android 14; CRT-AN00 Build/HONORCRT-AN00)';
  }
}