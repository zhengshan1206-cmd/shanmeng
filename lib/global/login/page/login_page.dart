/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:21
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-15 20:04:29
 * @FilePath: /ling_bao/lib/global/login/page/login_page.dart
 * @Description: 登录页面
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/util/extentions.dart';
import '../../../core/ui/page/base_page.dart';
import '../../../core/ui/view/by_widgets_util.dart';
import '../../launch/controller/launch_manager.dart';
import '../../launch/view/agreement_view.dart';
import '../../routes/app_pages.dart';
import '../../ui/colors.dart';
import '../../user/user.dart';
import '../binbing/login_binding.dart';
import '../controller/login_controller.dart';
import '../view/countdown_button.dart';
import '../view/login_textfield.dart';

///登录页面
// ignore: must_be_immutable
class LoginPage extends BasePage {
  LoginPage({super.key, this.type});
  LoginType? type;

  @override
  bool get hasAppBar => false;

  @override
  LoginController get controller {
    // 确保控制器正确初始化
    if (!Get.isRegistered<LoginController>()) {
      LoginBinding().dependencies();
    }
    return Get.find<LoginController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ByColor.colorBg1,
      body: buildBody(context),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: type == LoginType.wx ? 204.h : 102.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Image.asset(
                    'assets/global/launch/launch_logo.png',
                    width: 139.w,
                    height: 130.w,
                  ),
                ),

                SizedBox(height: 30.h),

                _buildPhoneLoginView(context),

                const Spacer(),

                checkProtocalView(),

                //   Obx(() => Offstage(
                //     offstage: !codeNode.hasFocus ||
                //       !phoneNode.hasFocus,
                //   child: SizedBox(height: 30.h),
                // )),
              ],
            ),
          ),
        ),
        Image.asset(
          'assets/global/login/icon_login_bg.png',
          fit: BoxFit.contain,
        ),
        if (controller.showClose!) closeView(),
        // if (type != LoginType.phone) phoneLoginView(),
        // if(Platform.isIOS && !controller.isBindMode.value && Get.find<LaunchController>().launchInfo?.verConfig.allowTouristsVip == 1)
        // visitorPay(),
      ],
    );
  }

  ///手机号码登录
  Widget _buildPhoneLoginView(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoginTextField(
              hintText: "请输入手机号",
              focusNode: controller.phoneNode,
              maxLength: 11,
              keyboardType: TextInputType.number,
              inputCallBack: (value) {
                controller.changePhoneNO(value);
              },
            ),
            SizedBox(height: 3.h),
            Obx(
              () => Offstage(
                offstage: controller.checkVCodeBtnEnabled(),
                child: Row(
                  children: [
                    // Image.asset(
                    //   "assets/mine/icon_info.png",
                    //   width: 12.w,
                    //   height: 12.w,
                    //   fit: BoxFit.contain,
                    // ),
                    SizedBox(width: 5.w),
                    ByWidgetsUtil.commonText(
                      text: "请输入正确的手机号码",
                      fontSize: 12.sp,
                      textColor: ByColor.colorC1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: ByColor.colorBg2,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Stack(
            children: [
              Positioned(
                child: LoginTextField(
                  // text: provider.vCode,
                  hintText: "请输入验证码",
                  focusNode: controller.codeNode,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  inputCallBack: (value) {
                    controller.changeVCode(value);
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Positioned(
                right: 4,
                top: 4,
                bottom: 4,
                child: SizedBox(
                  width: 94.w,
                  child: const CountDownBtn(
                    fontSize: 14,
                    textColor: ByColor.colorC1,
                    resendAfterText: "重新发送",
                    showBorder: true,
                    // getVCode: controller.getVCode,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Offstage(
            offstage: controller.vcodeInputRight.value,
            child: Row(
              children: [
                SizedBox(width: 5.w),
                ByWidgetsUtil.commonText(
                  text: "验证码错误",
                  fontSize: 12.sp,
                  textColor: ByColor.colorG4,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 35.h),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!controller.loginEnbled.value) return;
            FocusScope.of(context).unfocus();
            if (!controller.agreementChecked.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return LoginAgreementView(
                    callback: () {
                      FocusScope.of(context).unfocus();
                      controller.agreementCheckedStatusChanged(true);
                      if (controller.isBindMode.value) {
                        controller.bindPhone();
                      } else {
                        controller.loginWithVCode(context);
                      }
                    },
                  );
                },
              );
            } else {
              if (!controller.loginEnbled.value) return;
              if (controller.isBindMode.value) {
                controller.bindPhone();
              } else {
                controller.loginWithVCode(context);
              }
            }
          },
          child: Obx(
            () => Container(
              height: 48.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: controller.loginEnbled.value
                    ? ByColor.colorG1()
                    : null,
                color: controller.loginEnbled.value
                    ? null
                    : ByColor.colorC1.withAlphaValue(0.3),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: !controller.isLogin.value
                  ? Text(
                      controller.isBindMode.value ? "绑定" : "登录",
                      style: TextStyle(
                        color: controller.loginEnbled.value
                            ? ByColor.colorF0
                            : ByColor.colorF0.withAlphaValue(0.3),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : CupertinoActivityIndicator(
                      color: ByColor.colorF0,
                      radius: 10.w,
                    ),
            ),
          ),
        ),
        if (controller.isBindMode.value) SizedBox(height: 12.w),
        if (controller.isBindMode.value)
          ByWidgetsUtil.commonText(
            text: '*绑定账户后，可在任何设备恢复已购内容',
            textColor: ByColor.colorF1.withAlphaValue(0.5),
          ),
      ],
    );
  }

  ///用户协议与隐私
  Widget checkProtocalView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.agreementCheckedStatusChanged(
          !controller.agreementChecked.value,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            const Spacer(),
            if (Get.find<UserController>().isAudit())
              Obx(
                () => Image.asset(
                  controller.agreementChecked.value
                      ? "assets/pay/radio_selected.png"
                      : "assets/pay/radio_unselected.png",
                  width: 16.w,
                  height: 16.w,
                ),
              ),
            const SizedBox(width: 8),
            ByWidgetsUtil.commonRichText(
              texts: [
                const TextSpan(text: "已阅读并同意"),
                TextSpan(
                  text: "《用户协议》",
                  style: const TextStyle(color: ByColor.colorC1),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      GlobalController.instance.config.goPrivacyPageWithTitle(
                        '用户协议',
                      );
                    },
                ),
                const TextSpan(text: "和"),
                TextSpan(
                  text: "《隐私政策》",
                  style: const TextStyle(color: ByColor.colorC1),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      GlobalController.instance.config.goPrivacyPageWithTitle(
                        '隐私政策',
                      );
                    },
                ),
              ],
              fontSize: 12.sp,
              textColor: ByColor.colorF2.withAlphaValue(0.6),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  ///其他手机号登录按钮
  Widget phoneLoginView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      right: 12.w,
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(12.w),
          child: ByWidgetsUtil.commonText(
            bgColor: Colors.transparent,
            textColor: ByColor.colorC1,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            text: '其他手机号登录',
          ),
        ),
        onTap: () {
          Get.toNamed(Routes.loginPhone);
        },
      ),
    );
  }

  ///关闭按钮
  Widget closeView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      child: GestureDetector(
        onTap: () {
          // 清除待执行的操作
          Get.find<UserController>().clearPendingAction();
          Get.back();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 45.w,
          height: 45.w,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 6.w),
          child: Image.asset(
            "assets/global/common/btn_close.png",
            width: 36,
            height: 36,
          ),
        ),
      ),
    );
  }

  ///游客购买
  Widget visitorPay() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      right: 24.w,
      child: GestureDetector(
        onTap: () {
          // 清除待执行的操作
          controller.visitorForPayPage();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 45.w,
          alignment: Alignment.centerRight,
          child: ByWidgetsUtil.commonText(
            text: '不登录直接购买',
            textColor: ByColor.colorF1.withAlphaValue(0.5),
          ),
        ),
      ),
    );
  }
}
