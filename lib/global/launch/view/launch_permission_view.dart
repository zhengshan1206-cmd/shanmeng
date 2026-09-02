import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/widget/by_button.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_nav_router_utils.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/const/consts.dart';

import '../../ui/colors.dart';

class PermissionConfirmPage extends StatelessWidget {
  const PermissionConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg2,
      body: Stack(
        children: [
          Container(),
          // Positioned.fill(
          //   child: Image.asset(
          //     "assets/global/launch/launch_bg.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              color: ByColor.colorBg2,
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ByWidgetsUtil.commonContainer(
                  bgColor: ByColor.colorF0,
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 20.h,
                    bottom: 10.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ByText.text(
                        text: title ?? "欢迎使用闪梦Ai",
                        textColor: ByColor.colorF8,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      SizedBox(height: 15.h),
                      ByWidgetsUtil.commonRichText(
                        maxLines: 9999,
                        height: 1.3,
                        texts: [
                          TextSpan(
                            style: const TextStyle(color: ByColor.colorF8),
                            text:
                                content ??
                                "感谢您信任并使用闪梦Ai!\n我们将持续采取互联网行业通行的技术措施和数据安全保护措施，保护您的隐私和个人信息安全您可通过阅读完整的 ",
                          ),
                          TextSpan(
                            text: " 《用户协议》",
                            style: const TextStyle(color: ByColor.colorC1),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "用户协议",
                                  Consts.termsOfServiceUrl,
                                );
                              },
                          ),
                          const TextSpan(
                            style: TextStyle(color: ByColor.colorF8),
                            text: " 和",
                          ),
                          TextSpan(
                            text: " 《隐私政策》 ",
                            style: const TextStyle(color: ByColor.colorC1),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "隐私政策",
                                  Consts.privacyPolicyUrl,
                                );
                              },
                          ),
                          const TextSpan(
                            style: TextStyle(color: ByColor.colorF8),
                            text:
                                "了解详情。\n在上述协议中，我们将向您说明我们如何为您提供服务并保障您的用户权益，如何收集、使用、保存、共享和保护您的相关信息，以及为您提供的访问、修改、删除和您相关的信息的方式。我们会严格按照您的授权，在上述协议约定的范围内收集、存储和使用您注册信息、设备信息、日志信息、图片信息或其他经您授权的信息。使用本产品需要接入数据网络或WLAN网络。可能产生流量费用，具体详情需请您咨询当地运营商。如您已经充分阅读、理解并接受以上两份协议的内容，请您点击“同意并继续”开始接受我们的服务。",
                          ),
                        ],
                        fontSize: 13.sp,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 48.h,
                        width: double.infinity,
                        child: ByWidgetsUtil.gradientBtn(
                          title: confirmText ?? "同意并继续",
                          fontSize: 17.sp,
                          // titleColor: ByColor.colorF0,
                          // backgroundColor: ByColor.colorC1,
                          fontWeight: FontWeight.w600,
                          onClick: () async {
                            onConfirm.call();
                          },
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        height: 40.h,
                        width: double.infinity,
                        child: ByButton.textButton(
                          backgroundColor: Colors.transparent,
                          title: cancelText ?? "不同意",
                          fontSize: 14.sp,
                          titleColor: ByColor.colorF2,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return ExistConfirmPage(onConfirm: onConfirm);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExistConfirmPage extends StatelessWidget {
  const ExistConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          // Positioned.fill(
          //   child: Image.asset(
          //     "assets/global/launch/launch_bg.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              color: ByColor.colorBg2,
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ByWidgetsUtil.commonContainer(
                  bgColor: ByColor.colorF0,
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 20.h,
                    bottom: 20.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ByText.text(
                        text: title ?? "确认提示",
                        textColor: ByColor.colorF8,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      SizedBox(height: 15.h),
                      ByWidgetsUtil.commonRichText(
                        maxLines: 9999,
                        height: 1.8,
                        texts: [
                          TextSpan(text: content ?? "进入应用前，请先同意 "),
                          TextSpan(
                            text: "《用户协议》",
                            style: const TextStyle(color: ByColor.colorC1),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  Consts.termsOfServiceUrl,
                                );
                              },
                          ),
                          const TextSpan(text: " 和 "),
                          TextSpan(
                            text: "《隐私政策》",
                            style: const TextStyle(color: ByColor.colorC1),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  Consts.privacyPolicyUrl,
                                );
                              },
                          ),
                          const TextSpan(text: "，否则将退出应用。"),
                        ],
                        fontSize: 13.sp,
                        textColor: ByColor.colorF7,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 44.h,
                        child: Row(
                          children: [
                            Expanded(
                              child: ByWidgetsUtil.commonBtn(
                                padding: EdgeInsets.zero,
                                borderRadius: 12.w,
                                title: cancelText ?? "退出",
                                bgColor: ByColor.colorF2.withAlphaValue(0.5),
                                fontWeight: FontWeight.normal,
                                textColor: ByColor.colorF8,
                                fontSize: 16.sp,
                                onClick: () async {
                                  SystemNavigator.pop();
                                },
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: ByWidgetsUtil.gradientBtn(
                                padding: EdgeInsets.zero,
                                borderRadius: 12.w,
                                title: confirmText ?? "同意",
                                fontSize: 16.sp,
                                textColor: ByColor.colorF1,
                                fontWeight: FontWeight.w500,
                                onClick: () async {
                                  onConfirm.call();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
