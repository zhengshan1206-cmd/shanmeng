library;

import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ling_bao/core/ui/dialog/diolog_view.dart';
import 'package:ling_bao/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/by_package_utils.dart';
import 'byhy_permission_usage_bean.dart';

///  description: 封装permission_handler  todo 相关弹窗需要配置
extension PermissionExt on Permission {
  List<PermissionUsageBean> get permissionUsageBean {
    switch (this) {
      /// 定位权限
      case Permission.location:
      case Permission.locationWhenInUse:
      case Permission.locationAlways:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "定位权限(获取此设备的位置信息)",
            "usage": "用于为您提供您所在城市的实时天气预报，方便您填写您的兑换收货信息等服务。",
          }),
        ];
      case Permission.phone:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "手机卡权限",
            "usage": "用于一键登录使用。",
          }),
        ];
      case Permission.microphone:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "录制音频",
            "usage": "为了给您提供便捷的服务，我们将获取录制音频权限，用于上传文件生成内容。是否同意？",
          }),
        ];
      case Permission.storage:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "存储权限(访问设备照片、媒体内容和文件)",
            "usage": "为了给您提供便捷的服务，方便您上传原生文件以生成内容，以及下载生成后的文件，我们需要获取您的存储权限。是否同意？",
          }),
        ];
      case Permission.videos:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "媒体权限(访问设备照片、媒体内容和文件)",
            "usage": "为了给您提供便捷的服务，方便您上传原生文件以生成内容，以及下载生成后的文件，我们需要获取您的媒体权限。是否同意？",
            // "usage":
            // "为了给您提供便捷的服务，请确保您上传的照片、人脸、人声等信息已获得本人授权同意。本应用将使用 AI 深度合成技术处理您的生物特征信息，未获您明确同意前，不会采集和使用相关信息，方便您上传原生文件以生成内容，以及下载生成后的文件，我们需要获取您的媒体权限，是否同意？",
          }),
        ];
      case Permission.photos:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "媒体权限(访问设备照片、媒体内容和文件)",
            // "usage": "为了给您提供便捷的服务，方便您上传原生文件以生成内容，以及下载生成后的文件，我们需要获取您的媒体权限。是否同意？",
            "usage":
                "为了给您提供便捷的服务，请确保您上传的照片、人脸、人声等信息已获得本人授权同意。本应用将使用 AI 深度合成技术处理您的生物特征信息，未获您明确同意前，不会采集和使用相关信息，方便您上传原生文件以生成内容，以及下载生成后的文件，我们需要获取您的媒体权限，是否同意？",
          }),
        ];
      case Permission.camera:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "相机权限(访问设备相机功能)",
            "usage": "为了给您提供便捷的服务，我们将获取拍摄照片和录制视频权限，用于上传文件生成内容。是否同意？",
          }),
          Permission.microphone.permissionUsageBean.first,
        ];
      case Permission.audio:
        return [
          PermissionUsageBean.fromJson({
            "permissionName": "音频权限(访问设备音频内容和文件)",
            "usage":
                "用于选取您设备中的音频文件来作为素材使用，用于视频合成、文字提取等功能，请您确认授权，否则无法使用该功能相关规则请您仔细阅读设置页面中的《用户服务协议》和《隐私政策》。",
          }),
        ];
    }
    return [
      PermissionUsageBean.fromJson({
        "permissionName": "其他权限",
        "usage": "用于为您带来更好的应用体验。",
      }),
    ];
  }
}

class ByPermissionUtils {
  static Future<bool> _showPermissionUsageDialog(
    List<PermissionUsageBean> beans,
  ) async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      return true;
    }
    final result = await showDialog<bool>(
      context: ctx,
      builder: (context) {
        return PermissionUsageNovelDialog(permissionBeans: beans);
      },
    );
    return result == true;
  }

  /// 请求权限
  static Future<bool> _requestPermission(
    Permission permission,
    String message, {
    bool needMicroPhone = false,
  }) async {
    log("当前权限的状态=======${permission.toString()}");

    /// 2、弹出系统的权限授权弹窗
    var status = await permission.status;
    if (status.isGranted || status.isLimited) {
      if (Platform.isIOS) {
        if (permission == Permission.camera) {
          PermissionStatus permissionStatus = await Permission.photos.request();
          PermissionStatus permissionStatus2 = await Permission.microphone
              .request();
          if (permissionStatus.isPermanentlyDenied) {
            _showDialog("暂无相册权限，请前往设置开启权限");
            return false;
          }
          if (needMicroPhone) {
            if (permissionStatus2.isPermanentlyDenied) {
              _showDialog("暂无麦克风权限，请前往设置开启权限");
              return false;
            }
          }
        }
      }
      return true;
    }

    /// 3、权限被拒绝
    if (Platform.isAndroid) {
      ///安卓情况
      if (status.isDenied) {
        final agreed = await _showPermissionUsageDialog(
          permission.permissionUsageBean,
        );
        if (!agreed) return false;
        PermissionStatus permissionStatus = await permission.request();
        if (permissionStatus.isGranted || permissionStatus.isLimited) {
          return true;
        }
        if (permissionStatus.isPermanentlyDenied || permissionStatus.isDenied) {
          _showDialog(message);
          return false;
        }
        return false;
      }
    } else if (Platform.isIOS) {
      /// iOS：保持与改前一致，直接走系统授权（说明弹窗仅在 Android 展示）
      if (status.isDenied) {
        final PermissionStatus permissionStatus = await permission.request();
        log("当前ios权限的状态=======${permissionStatus.isDenied}");
        if (permissionStatus.isGranted || permissionStatus.isLimited) {
          return true;
        }
        if (permissionStatus.isPermanentlyDenied) {
          _showDialog(message);
          return false;
        }
      }
    }

    /// 4、权限被永久拒绝
    if (status.isPermanentlyDenied) {
      _showDialog(message);
      return false;
    }
    return false;
  }

  /// 前往设置界面的提示弹窗
  static void _showDialog(String message) {
    Future.delayed(const Duration(milliseconds: 200), () {
      final BuildContext? ctx = navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      showDialog<void>(
        context: ctx,
        builder: (context) {
          return NovelDialog(
            title: '温馨提示',
            content: message,
            cancelText: '暂不开启',
            confirmText: '前往设置',
            onConfirm: () {
              openAppSettings();
            },
          );
        },
      );
    });
  }

  // 打开App权限设置页面
  static Future<void> openPermissionSettings() async {
    final String packageName = await ByPackageUtils.appName(); // 获取当前App包名

    Uri url;
    if (Platform.isIOS) {
      // iOS：直接跳转到App设置页面（包含权限选项）
      url = Uri.parse('app-settings:');
    } else {
      // Android：跳转到App详细信息页面（权限设置在此页面内）
      url = Uri.parse(
        'android.settings.APPLICATION_DETAILS_SETTINGS?package=$packageName',
      );
    }

    // 尝试跳转
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // 跳转到系统应用（非App内）
      );
    } else {}
  }

  /// 相册 权限检查和请求
  static Future<bool> photos({String message = '暂无相册权限，请前往设置开启权限'}) async {
    Permission permission = Permission.photos;
    if (ByPackageUtils.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }
    bool isGranted = await _requestPermission(permission, message);
    return isGranted;
  }

  /// 相册 权限检查和请求
  static Future<bool> audios({String message = '暂无相册权限，请前往设置开启权限'}) async {
    Permission permission = Permission.audio;
    if (ByPackageUtils.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        permission = Permission.storage;
      } else {
        permission = Permission.audio;
      }
    }
    bool isGranted = await _requestPermission(permission, message);
    return isGranted;
  }

  ///sim卡权限
  static Future<bool> phone({String message = '暂无手机号权限，请前往设置开启权限'}) async {
    bool isGranted = await _requestPermission(Permission.phone, message);
    return isGranted;
  }

  /// 相机 权限检查和请求
  static Future<bool> camera({
    String message = '暂无相机权限，请前往设置开启权限',
    bool needMicroPhone = false,
  }) async {
    bool isGranted = await _requestPermission(
      Permission.camera,
      message,
      needMicroPhone: needMicroPhone,
    );
    return isGranted;
  }

  /// 麦克风 权限检查和请求
  static Future<bool> microphone({String message = '暂无麦克风权限，请前往设置开启权限'}) async {
    bool isGranted = await _requestPermission(Permission.microphone, message);
    return isGranted;
  }

  /// 手机存储 权限检查和请求
  static Future<bool> storage({String message = '暂无手机存储权限，请前往设置开启权限'}) async {
    return await appStorage();
  }

  /// 手机存储 权限检查和请求
  static Future<bool> videos({String message = '暂无手机视频权限，请前往设置开启权限'}) async {
    return await appStorage();
  }

  /// 手机存储 权限检查和请求
  static Future<bool> systemAlertWindow({
    String message = '暂无悬浮窗权限，请前往设置开启权限',
  }) async {
    return await _requestPermission(Permission.systemAlertWindow, message);
  }

  ///手机存储权限
  static Future<bool> appStorage({
    String message = '暂无手机音视频存储权限，请前往设置开启权限',
  }) async {
    if (ByPackageUtils.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      int sdkInt = androidInfo.version.sdkInt;
      return sdkInt >= 33
          ? await _requestPermission(Permission.videos, message)
          : await _requestPermission(Permission.storage, message);
    } else {
      return await _requestPermission(
        Permission.photos,
        "暂无手机相册视频权限，请前往设置开启权限",
      );
    }
  }

  ///ios 手机
  static Future<bool> iosAudios({String message = '暂无音频访问权限，请前往设置开启权限'}) async {
    Permission permission = Permission.mediaLibrary;
    bool isGranted = await _requestPermission(permission, message);
    return isGranted;
  }
}
