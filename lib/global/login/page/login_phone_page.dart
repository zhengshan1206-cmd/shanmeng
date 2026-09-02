/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:21
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:35:23
 * @FilePath: /ling_bao/lib/global/login/page/login_phone_page.dart
 * @Description: 登录页面
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/page/base_page.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/login/binbing/login_binding.dart';
import 'package:ling_bao/global/login/controller/login_controller.dart';
import 'package:ling_bao/global/routes/app_pages.dart';
import 'package:ling_bao/global/ui/colors.dart';
import '../../user/user.dart';
import '../view/login_textfield.dart';

///登录页面
// ignore: must_be_immutable
class LoginPhonePage extends BasePage {
  LoginPhonePage({super.key, this.type});
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
        Image.asset(
          'assets/global/login/icon_login_bg.png',
          fit: BoxFit.contain,
        ),
        Positioned(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: type == LoginType.wx ? 204.h : 102.h),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.w),
                      child: Image.asset(
                        'assets/icon.png',
                        width: 80.w,
                        height: 80.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ByWidgetsUtil.commonRichText(
                          texts: [
                            TextSpan(
                              text: '',
                              style: TextStyle(
                                color: ByColor.colorF1,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'No Experience Limit',
                              style: TextStyle(
                                color: const Color(0xFFFEA324),
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: '',
                              style: TextStyle(
                                color: ByColor.colorF1,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ByText.text(
                              text: 'Log in to Penman Pro',
                              // fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              // textColor: const Color(0xFFFEA324)
                            ),
                            SizedBox(width: 4.w),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 40.h),
                SizedBox(height: 2.h),

                _buildPhoneLoginView(context),

                const Spacer(),

                // checkProtocalView(),

                //   Obx(() => Offstage(
                //     offstage: !codeNode.hasFocus ||
                //       !phoneNode.hasFocus,
                //   child: SizedBox(height: 30.h),
                // )),
              ],
            ),
          ),
        ),
        closeView(),
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
              hintText: "Account(11 numbers)",
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
                    ByText.text(
                      text: "请输入正确的账号",
                      fontSize: 12.sp,
                      textColor: ByColor.colorG4,
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
                  hintText: "Enter the password",
                  focusNode: controller.codeNode,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  inputCallBack: (value) {
                    controller.changeVCode(value);
                  },
                ),
              ),
              SizedBox(width: 10.w),
              // Positioned(
              //   right: 4,
              //   top: 4,
              //   bottom: 4,
              //   child: SizedBox(
              //     width: 94.w,
              //     child: const CountDownBtn(
              //       fontSize: 14,
              //       textColor: ByColor.colorC1,
              //       resendAfterText: "重新发送",
              //       showBorder: true,
              //       // getVCode: controller.getVCode,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        Obx(
          () => Offstage(
            offstage: controller.vcodeInputRight.value,
            child: Row(
              children: [
                SizedBox(width: 5.w),
                ByText.text(
                  text: "password error",
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
            if (!controller.loginEnbled.value) return;
            controller.loginWithVCode(context);
          },
          child: Obx(
            () => Container(
              height: 48.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: controller.loginEnbled.value
                    ? ByColor.colorC1
                    : ByColor.colorC1.withAlphaValue(0.3),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Obx(
                () => !controller.isLogin.value
                    ? Text(
                        "Log in",
                        style: TextStyle(
                          color: controller.loginEnbled.value
                              ? Colors.black
                              : Colors.black.withAlphaValue(0.4),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : CupertinoActivityIndicator(
                        color: Colors.black,
                        radius: 10.w,
                      ),
              ),
            ),
          ),
        ),
      ],
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
          child: ByText.text(
            bgColor: Colors.transparent,
            textColor: ByColor.colorC1,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            text: 'Sign in with Phone',
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
          margin: EdgeInsets.only(left: 16.w),
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
          child: ByText.text(
            text: '不登录直接购买',
            textColor: ByColor.colorF1.withAlphaValue(0.5),
          ),
        ),
      ),
    );
  }
}
