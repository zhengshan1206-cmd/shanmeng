import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_nav_router_utils.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/ui/colors.dart';

typedef LoginAgreementCallback = void Function();

class LoginAgreementView extends StatelessWidget {
  const LoginAgreementView({
    super.key,
    this.btnTitle,
    this.callback,
    this.registerMember = false,
    this.isIntegral = false, //是否积分页面
    this.color1,
    this.isLoginSend = false,
  });

  final String? btnTitle;
  final LoginAgreementCallback? callback;

  final bool registerMember;

  final bool isIntegral;

  final Color? color1;

  //是否是登录页发送弹窗
  final bool isLoginSend;

  @override
  Widget build(BuildContext context) {
    // 确保在构建时加载 VIP 数据

    return Center(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 28.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: ByColor.colorBg2,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 45.h),
                ByWidgetsUtil.commonRichText(
                  maxLines: 999,
                  height: 1.6,
                  texts: [
                    const TextSpan(
                      style: TextStyle(color: Colors.white),
                      text: "请仔细阅读",
                    ),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "《用户协议》",
                          style: const TextStyle(color: ByColor.colorC1),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config.goPrivacyPageWithTitle('用户协议');
                            },
                        ),
                        const TextSpan(
                          style: TextStyle(color: Colors.white),
                          text: "和",
                        ),
                        TextSpan(
                          text: "《隐私政策》",
                          style: const TextStyle(color: ByColor.colorC1),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config.goPrivacyPageWithTitle('隐私政策');
                            },
                        ),
                      ],
                    ),
                    const TextSpan(
                      style: TextStyle(color: Colors.white),
                      text: "确认是否同意",
                    ),
                  ],
                  textColor: ByColor.colorC1,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 30.h),
                GestureDetector(
                  onTap: () {
                    ByNavRouterUtils.goBack(context);
                    callback?.call();
                  },
                  child: Container(
                    height: 44.h,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: ByColor.colorG1(),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: ByText.text(
                      text: btnTitle ?? "同意并登录",
                      textColor: ByColor.colorF1,
                      fontSize: 14.sp,
                      bgColor: ByColor.colorC1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          Positioned(
            right: 38.w,
            top: 10.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 32.w,
                height: 32.w,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/global/common/btn_close.png",
                  width: 32.w,
                  height: 32.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
