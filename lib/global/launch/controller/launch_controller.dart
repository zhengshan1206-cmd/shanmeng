import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/cache/byhy_aes_storage_utils.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/const_keys.dart';
import 'package:ling_bao/core/network/dio_utils.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/core/network/intercept.dart';
import 'package:ling_bao/core/network/novel_apis.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/util/by_device_info_utils.dart';
import 'package:ling_bao/core/util/by_package_utils.dart';
import 'package:ling_bao/global/const/const_string.dart';
import 'package:ling_bao/global/initiliazation/initialize.dart';
import 'package:ling_bao/global/attribution/by_ascribe_util.dart';
import 'package:ling_bao/global/launch/bean/launch_bean.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/launch/view/launch_permission_view.dart';

import '../../../core/cache/cache.dart';
import '../../routes/app_pages.dart';
import '../../user/user.dart';

typedef LaunchSuccessCallback = void Function(LaunchInfoBean);
typedef LaunchFailCallback = void Function();

class LaunchController extends GetxController {
  RxInt launchDialogCount = 0.obs;
  RxBool forcePauseLaunchVideo = false.obs;

  bool get hasLaunchOverlayDialog => launchDialogCount.value > 0;
  LaunchInfoBean? launchInfo;

  RxBool isLaunched = false.obs;

  ///是否加载过启动页

  ///是否正在加载
  bool isLoading = false;

  PayData payData = GlobalController.instance.pay;

  Timer? _timer;

  ///五角星显示个数
  RxInt starCount = 0.obs;

  ///计时数量
  RxInt timerCount = 0.obs;

  /// 网络状态是否有网络
  bool hasNetwork = false;

  void setForcePauseLaunchVideo(bool value) {
    forcePauseLaunchVideo.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    _checkStartConfig();
    _checkNetworkPermission();
  }

  /// 是否是iOS首次进入需要网络授权
  bool needNetworkAuth() {
    if (Platform.isIOS && !hasGuide()) {
      return true;
    }
    return false;
  }

  /// 检查网络权限
  void _checkNetworkPermission() async {
    if (needNetworkAuth()) {
      ///检查是否有网络链接
      var connectivityResult = await (Connectivity().checkConnectivity());
      Get.log("===connectivityResult=== ${connectivityResult.first}");
      if (connectivityResult.first == ConnectivityResult.none) {
        hasNetwork = false;
      }
    } else {
      hasNetwork = true;
    }
  }

  /// 进度loading
  void _loadProgress() {
    _timer = Timer.periodic(Duration(milliseconds: 10), (_) {
      starCount.value = (timerCount.value / 50).floor();
      if (starCount.value >= 5) {
        _timer?.cancel();
        if (hasGuide()) {
          try {
            ///配置直接进入付费页
            final UserController user = Get.find<UserController>();
            if (launchInfo?.config != null &&
                launchInfo!.config!.launchPage != 1 &&
                !user.isVip) {
              setForcePauseLaunchVideo(true);
              user.jumpToPayPage(isBackHome: true);
            } else {
              Get.offNamed(Routes.main);
            }
          } catch (e) {
            Get.offNamed(Routes.main);
          }
        }
      } else {
        timerCount.value++;
      }
    });
  }

  ///检查启动配置信息
  void _checkStartConfig() {
    final String startData =
        ByStorageUtils.getString(ConstString.kStartConfig) ?? '';
    if (startData.isEmpty) {
      return;
    } else {
      final Map mapData = jsonDecode(startData);

      ///验证token是否过期
      final String token = mapData['token'];
      print('________token_$token');
      isLaunched.value = true;
      _handleStartData(mapData, isRefresh: false);
    }
  }

  ///启动页检查
  void checkAgreement() async {
    ///检查是否有网络链接

    final checked = await LocalCacheManager.readJsonData(
      ConstString.kSPPrivacyChecked,
    );
    print('是否看过隐私协议：_____$checked');
    if (!hasNetwork && Platform.isIOS) {
      return;
    }
    if (checked.isNotEmpty) {
      _loadProgress();
      appLaunch();
      Future.delayed(const Duration(seconds: 1), () {
        launchSuccessful();
      });
    } else {
      showCheckDialog();
    }
  }

  ///失败启动，检查隐私页
  void showCheckDialog() {
    launchDialogCount.value++;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (ctx) {
        return PermissionConfirmPage(
          onConfirm: () async {
            Get.back();
            _loadProgress();
            LocalCacheManager.saveJsonData(ConstString.kSPPrivacyChecked, '1');
            appLaunch();
            launchSuccessful();
          },
        );
      },
    ).then((_) {
      if (launchDialogCount.value > 0) {
        launchDialogCount.value--;
      }
    });
  }

  ///是否进入过引导页
  bool hasGuide() {
    final guideChecked =
        ByStorageUtils.getBool(ConstString.kLaunchGuideCheck) ?? false;
    return guideChecked;
  }

  ///进入引导流程页面
  void gotoGuide({bool backHome = false, bool isGuide = true}) {
    Get.offNamed(Routes.guide);
    // Get.offNamed(
    //   Routes.payCenterPage,
    //   arguments: {'guide': isGuide, 'isBackHome': backHome},
    // );
  }

  ///成功启动后
  void launchSuccessful() {
    ///网络链路正常后初始化sdk
    InitializeManager.initSDK();
    print('是否看过引导页：_____${hasGuide()}');
    if (hasGuide()) {
      // Get.offNamed(Routes.main);
    }
  }

  ///启动接口
  void appLaunch({
    LaunchSuccessCallback? onSuccess,
    LaunchFailCallback? onFail,
  }) async {
    if (!isLaunched.value && !isLoading) {
      ByDeviceInfoUtils.saveAddressByIp();
    }
    if (isLoading) {
      return;
    }
    isLoading = true;
    final imei = await ByDeviceInfoUtils.deviceInfo();
    final String system = ByPackageUtils.isAndroid
        ? ConstString.kSystemAndroid
        : ConstString.kSystemIOS;
    Map params = {};
    print("_________imei==$imei");
    params = {
      "uuid": imei.item2,
      "app_version": ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "1.0.0",
      "sys": system,
    };

    HttpUtils.request(
      Method.post,
      NovelApis.launch,
      forceData: false,
      showMsgWhenFailed: true,
      params,
      success: (data) async {
        isLoading = false;
        final responseData = data["data"];
        _handleStartData(responseData, onSuccess: onSuccess);
      },
      fail: (code, msg) {
        isLoading = false;
        payData.statusType.value = MultiStatusType.statusNoNetWork;
        onFail?.call();
      },
    );
  }

  ///处理启动数据
  void _handleStartData(
    dynamic responseData, {
    bool isRefresh = true,
    LaunchSuccessCallback? onSuccess,
  }) {
    final LaunchInfoBean launchInfoBean = LaunchInfoBean.fromJson(responseData);
    launchInfo = launchInfoBean;
    final token = launchInfoBean.token;

    /// 保存token
    setToken(token)?.then((onValue) {
      if (onValue && isRefresh) {
        if (responseData.isNotEmpty) {
          ByStorageUtils.saveString(
            ConstString.kStartConfig,
            jsonEncode(responseData),
          );
        }

        /// 上报设备信息
        DeviceInfoUpload.uploadUserDeviceInfo();
        Get.find<UserController>().initinfo();
        isLaunched.value = true;

        ///初始化配置数据
        if (!hasGuide()) {
          GlobalController.instance.init();
        }

        /// 回调
        onSuccess?.call(launchInfoBean);
      }
    });
  }
}

/// 上报用户设备信息
class DeviceInfoUpload {
  static final DeviceInfoUpload instance = DeviceInfoUpload._internal();
  DeviceInfoUpload._internal();

  /// 上传状态
  int isUploaded = 0;

  /// 有推送token时加入推送token
  static void uploadUserDeviceInfo({String? pushToken}) async {
    await ByAscribeUtil.iniBDConvert();
    final params = await ByDeviceInfoUtils.getUserDiviceInfo();

    instance.isUploaded = 1;

    /// 开始上传
    HttpUtils.post(
      APIs.deviceInfo,
      showMsgWhenFailed: false,
      params,
      success: (data) {
        instance.isUploaded = 2;

        /// 完成上传
        Get.log("~~~~~上报设备信息成功$data,$pushToken");
      },
      fail: (code, msg) {},
    );
  }
}
