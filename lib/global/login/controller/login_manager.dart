/*
 * @Author: cold-x
 * @Date: 2025-06-09 11:08:18
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 11:44:32
 * @FilePath: /ling_bao/lib/global/login/controller/login_manager.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:ling_bao/global/login/controller/login_controller.dart';
import 'package:ling_bao/global/login/controller/onekey_manager.dart';
import '../../../core/network/intercept.dart';
import '../../../core/ui/dialog/toast.dart';
import '../../launch/bean/launch_bean.dart';
import '../../launch/controller/launch_controller.dart';
import '../../user/user.dart';
import '../bean/login_bean.dart';
import '../view/first_login_dialog.dart';

class LoginManager {
  static final LoginManager _instance = LoginManager._internal();
  factory LoginManager() => _instance;
  LoginManager._internal();

  static void login({
    String? source = 'normal',
    bool? binding = false,
    bool? isGuide = false,
    Function(String)? onSuccess,
    Function()? failed,
  }) {
    // _instance.getPayStyle();
    // if (Get.find<UserController>().isVisitor) {
    //   Get.toNamed(
    //     Routes.login,
    //     arguments: {
    //       "onLoginSuccess": successLogin,
    //       "bind": binding,
    //       "isGuide": isGuide,
    //       'source': source,
    //     },
    //   );
    // }
    OneKeyManager.onekeyLogin(
      isBindMode: binding,
      source: source,
      onSuccess: onSuccess,
      failed: failed,
    );
  }

  ///登录成功
  static Future<void> handleLoginResponse(
    dynamic data, {
    bool? binding = false,
    LoginType? type,
    void Function(dynamic, int)? onSuccess,
  }) async {
    // 根据是否为绑定模式显示不同的提示
    final successMessage = binding! ? 'binding success' : 'login success';
    Toast.showText(text: successMessage);

    if (data["status"] != 200) return;

    final LoginInfoBean userInfo = LoginInfoBean.fromJson(data["data"]);
    userInfo.isFormal = 1;

    LaunchInfoBean? launchInfo = Get.find<LaunchController>().launchInfo;
    launchInfo?.userId = userInfo.userId;
    launchInfo?.isVip = userInfo.isVip;
    launchInfo?.token = userInfo.token;
    launchInfo?.isFormal = userInfo.isFormal ?? 1;

    ///存储本地信息
    setToken(userInfo.token)?.then((onValue) {
      if (onValue) {
        Get.find<UserController>().reloadUserInfo(
          successAction: (userInfo) {
            if (Get.isRegistered<LoginController>()) {
              Get.back();
            }

            /// 显示赠送字数弹窗
            FirstLoginDialogManager.showLoginDialog(
              launchInfo?.hasGiveWords! == 1,
            );
            onSuccess?.call(data, 1);
          },
        );
      }
    });
  }
}
