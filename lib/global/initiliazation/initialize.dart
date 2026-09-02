/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:37
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-26 15:55:20
 * @FilePath: /ling_bao/lib/global/initiliazation/initialize.dart
 * @Description: 初始化器
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ling_bao/core/cache/byhy_aes_storage_utils.dart';
import 'package:ling_bao/core/network/const_keys.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/core/util/by_device_info_utils.dart';
import 'package:ling_bao/core/util/by_package_utils.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sp_util/sp_util.dart';
import 'package:wechat_kit/wechat_kit.dart';
import '../ui/colors.dart';

class WxLoginConfig {
  static const String kWechatAppID = 'wxa5307a7d6724b57a';
  static const String kWechatUniversalLink =
      'https://inchat.beiyinapp.com/app/';
}

///App 初始化器
class InitializeManager {
  ///初始化SDK
  static void initSDK() async {
    if (Platform.isIOS) {
      await _requestTrackingAuthorization();
    }
  }

  ///初始化组件
  static Future<void> initializition() async {
    // 设置状态栏透明
    initStatusBar();

    /// 初始化PF
    await _initPF();

    final version = await ByPackageUtils.version();
    await ByStorageUtils.saveString(ConstKeys.kAppVersion, version);
    await ConstKeys().initUserAgentData();
    ByDeviceInfoUtils.saveTimeZone();
    await initWechatSDK();
    // if(Platform.isAndroid) {
    //   ByDeviceInfoUtils.savePosition();
    // }
  }

  /// 初始化微信sdk
  static Future<void> initWechatSDK() async {
    await WechatKitPlatform.instance.registerApp(
      appId: WxLoginConfig.kWechatAppID,
      universalLink: WxLoginConfig.kWechatUniversalLink,
    );
  }

  // 请求广告追踪授权
  static Future<void> _requestTrackingAuthorization() async {
    // 1. 检查 iOS 版本是否支持（需 iOS 14+）
    // final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    // if (status == TrackingStatus.notDetermined) {
    //   // 2. 显示授权弹窗（会触发系统弹窗）
    //   Future.delayed(const Duration(milliseconds: 500),() async{
    //     await AppTrackingTransparency.requestTrackingAuthorization();
    //   });
    // }

    // // 3. 授权后可获取 IDFA（可选）
    // if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.authorized) {
    //   final idfa = await AdvertisingId.id;
    //   print("用户已授权，IDFA: $idfa");
    // } else {
    //   print("用户未授权或设备不支持");
    // }
  }

  static void initStatusBar() {
    // 设置状态栏透明
    SystemChrome.setSystemUIOverlayStyle(initOverlayStyle());
  }

  static SystemUiOverlayStyle initOverlayStyle() {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏透明
      statusBarIconBrightness: Brightness.light, // 状态栏图标颜色（深色/浅色）
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: ByColor.colorBg1,
      systemNavigationBarDividerColor: Colors.transparent, // 分隔线颜色
    );
  }

  ///初始化本地化组件
  static Future<void> _initPF() async {
    await SpUtil.getInstance(); // 这里也要 await
  }

  ///初始化上下拉刷新配置
  static RefreshConfiguration initRefresh(Widget child) {
    return ByRefresh.configuration(child: child);
  }
}
