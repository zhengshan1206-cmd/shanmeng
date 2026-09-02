import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import '../../core/cache/byhy_aes_storage_utils.dart';
import '../../core/network/apis.dart';
import '../../core/network/http_utils.dart';
import '../../core/ui/dialog/toast.dart';
import '../const/const_string.dart';
import '../launch/bean/launch_bean.dart';
import '../launch/controller/launch_controller.dart';
import '../login/controller/login_manager.dart';
import '../pay/bean/pay_preview_media.dart';
import '../pay/controller/pay_controller.dart';
import '../pay/page/pay_interal_page.dart';
import '../routes/app_pages.dart';
import 'user_bean.dart';

class UserController extends GetxController {
  ///用户信息
  final Rx<UserInfoBean?> userInfoBean = Rx<UserInfoBean?>(null);

  /// 银行卡签约H5返回通知（用于会员页触发查单）
  final RxInt bankSignReturnTick = 0.obs;

  ///是否可以前置登录
  bool isPreLogin = false;

  /// 存储被前置登录限制的操作回调
  VoidCallback? _pendingActionCallback;

  ///是否可以尝试
  bool couldTry = false;

  ///是否是游客，当前是否未登录
  bool get isVisitor {
    return userInfoBean.value?.isFormal == 0;
  }

  ///是否是会员
  bool get isVip {
    return userInfoBean.value?.isVip == 1;
  }

  /// 动态获取 launchInfo
  LaunchInfoBean? get launchInfo {
    try {
      return Get.find<LaunchController>().launchInfo;
    } catch (e) {
      print("获取 launchInfo 失败: $e");
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    initLocalUserData();
  }

  ///初始化本地用户数据
  void initLocalUserData() {
    final String userData =
        ByStorageUtils.getString(ConstString.kUserData) ?? '';
    if (userData.isEmpty) {
      return;
    }
    UserInfoBean bean = UserInfoBean.fromJson(jsonDecode(userData));
    userInfoBean.value = bean;
  }

  ///初始化loading用户信息
  void initinfo() {
    reloadUserInfo();
    // getCouldUse();
    preLoginConfig();
  }

  ///获取用户当前字数包字数
  ///是否需要显示详细字数
  String getUserWords({bool? needDetail = false}) {
    final userInfo = userInfoBean.value;
    final words = userInfo?.wordsPack != null ? '${userInfo?.wordsPack}' : '0';
    if (needDetail!) {
      return words;
    }
    return '000';
  }

  Future<void> getUserInfo({
    void Function(UserInfoBean? userInfo)? onSuccess,
  }) async {
    HttpUtils.get(
      APIs.loadUserInfo,
      {},
      success: (data) {
        final userInfoData = data["data"];
        UserInfoBean bean = UserInfoBean.fromJson(userInfoData);
        userInfoBean.value = bean;
        ByStorageUtils.saveString(
          ConstString.kUserData,
          jsonEncode(userInfoData),
        );
        onSuccess?.call(bean);
      },
      fail: (code, msg) {},
    );
  }

  ///更新用户信息
  Future reloadUserInfo({
    void Function(UserInfoBean? userInfo)? successAction,
    VoidCallback? goBack,
  }) async {
    await getUserInfo(
      onSuccess: (userInfo) {
        Get.log("保存用户数据===>${userInfo?.toJson()}");
        if (goBack != null) {
          goBack();
        }
        if (successAction != null) {
          successAction(userInfo);
        }
      },
    );
  }

  /// 该用户是否在审核面
  bool isAudit() {
    /// 是否在审核
    if (launchInfo?.isAudit == 1) {
      return true;
    }

    /// 是否已归因 ，是否在归因监测内
    // if(userInfoBean.value?.hasAttribution == 0 && userInfoBean.value?.isNewAttributionUser == 0) {
    //   return true;
    // }
    return false;
  }

  ///清空用户信息
  void clearUserInfo() {
    userInfoBean.value = null;
  }

  /// 获取所有配置
  void preLoginConfig({void Function()? onSuccess}) {
    HttpUtils.get(
      APIs.getConfig,
      {"group": "shan_meng"},
      success: (data) {
        /// 登录前置
        try {
          final config = data["data"]["deng_lu_qian_zhi"];
          if (config != null && config is! List) {
            if (config['val_text'] == "1") {
              isPreLogin = true;
              update();
            }
          }
        } catch (e) {
          // throw(e);
        }

        /// OB拦截弹窗
        try {
          final config = data["data"]["OB_lan_jie_tao_can"];
          if (config != null && config is! List) {
            final packageID = config['val_text'];
            GlobalController.instance.pay.loadPackageData(
              id: packageID,
              type: 1,
            );
          }
        } catch (e) {
          // throw(e);
        }

        /// 新用户立减套餐
        try {
          final config = data["data"]["li_jian_800_yuan_jia_tao_can"];
          if (config != null && config is! List) {
            final packageID = config['val_text'];
            GlobalController.instance.pay.loadPackageData(
              id: packageID,
              type: 2,
            );
          }
        } catch (e) {
          // throw(e);
        }
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
      },
    );
  }

  ///根据启动页下发路径，跳转不同付费页面
  ///是否直接返回首页，默认false
  ///是否需要显示特定的付费SKU弹窗
  ///[isWordsEmpty]字数包付费页样式
  void jumpToPayPage({
    String? payPage,
    bool isBackHome = false,
    String source = 'unknown',
    String url = '',
    PayPreviewPayload? previewPayload,
    void Function()? back,
  }) {
    if (Get.currentRoute == Routes.launch &&
        Get.isRegistered<LaunchController>()) {
      Get.find<LaunchController>().setForcePauseLaunchVideo(true);
    }

    /// 跳转至字数包弹窗
    if (isVip) {
      /// 跳转至字数包
      showGeneralDialog(
        context: Get.context!,
        pageBuilder: (context, animation, secondaryAnimation) {
          return MemberWordsPackagePage(isBackHome: isBackHome, source: source);
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.fastOutSlowIn.transform(animation.value);
          return Transform.translate(
            offset: Offset(0, (1 - curve) * 200),
            child: Opacity(opacity: curve, child: child),
          );
        },
      ).then((_) {
        // 对话框关闭后的回调（覆盖所有关闭场景的最终保险）
        if (Get.isRegistered<PayController>()) {
          Get.delete<PayController>();
        }
        back?.call();
      });
      return;
    }
    Get.toNamed(
      Routes.payCenterPage,
      arguments: {
        'isBackHome': isBackHome,
        'url': url,
        'preview_payload': previewPayload?.toJson(),
      },
    )?.then((_) {
      back?.call();
    });
  }

  ///检查是否前置登录
  /// [actionCallback] 如果需要登录，登录成功后要执行的操作

  void checkPreLogin({
    VoidCallback? actionCallback,
    String? source,
    bool binbing = false,
  }) {
    if (userInfoBean.value?.isFormal == 0 && !binbing) {
      // 保存被限制的操作回调
      if (actionCallback != null) {
        _pendingActionCallback = actionCallback;
      }
      LoginManager.login(source: source, onSuccess: _executePendingAction);
    } else {
      ///未开启前置登录，未登录并且是会员，则强制绑定
      if (userInfoBean.value?.isFormal == 0 && userInfoBean.value?.isVip == 1) {
        LoginManager.login(
          source: source,
          binding: true,
          onSuccess: _executePendingAction,
        );
        return;
      }
      actionCallback?.call();
    }
  }

  /// 执行被前置登录限制的操作
  void _executePendingAction(String desc) {
    if (_pendingActionCallback != null) {
      _pendingActionCallback!();
      _pendingActionCallback = null; // 执行后清空回调
    }
  }

  /// 清除待执行的操作（用于正常关闭登录页面时）
  void clearPendingAction() {
    _pendingActionCallback = null;
  }

  /// 通知：银行卡签约H5已返回
  void notifyBankSignReturned() {
    bankSignReturnTick.value++;
  }
}
