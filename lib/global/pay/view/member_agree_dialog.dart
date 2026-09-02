import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/pay/bean/vip_type_bean.dart';
import 'package:ling_bao/global/pay/controller/pay_controller.dart';

class MemberAgreeDialog extends StatelessWidget {
  const MemberAgreeDialog({super.key, this.onConfirm});

  final Function()? onConfirm;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayController>();
    final List<dynamic> packages = controller.getCurrentDataList();
    final int index = controller.payManager.selectIndex.value;
    final bool isSubscribeVipPackage =
        controller.payType.value == .vip &&
        packages.isNotEmpty &&
        index >= 0 &&
        index < packages.length &&
        packages[index] is VipTypeBean &&
        ((packages[index] as VipTypeBean).isSubscribe ?? 0) == 1;

    return Material(
      color: Colors.black.withValues(alpha: 0.36),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: SizedBox(
          width: 1.sw,
          height: 530.h,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/pay/icon_pay_agree_bg.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Positioned(
                    right: 58.w,
                    top: 168.h,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: Get.back,
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20.w,
                          color: const Color(0xFFE4B258),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 72.w,
                    right: 72.w,
                    top: 195.h,
                    child: ByText.text(
                      text: '确认开通',
                      textAlign: TextAlign.center,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w600,
                      textColor: const Color(0xFFFA3E05),
                    ),
                  ),
                  Positioned(
                    left: 72.w,
                    right: 72.w,
                    top: 260.h,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '请阅读并同意',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8D7E61),
                            ),
                          ),
                          if (controller.payType.value == .vip)
                            TextSpan(
                              text: '《会员服务协议》',
                              style: TextStyle(
                                color: const Color(0xFFFF8A12),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  GlobalController.instance.config
                                      .goPrivacyPageWithTitle('会员服务协议');
                                },
                            ),
                          if (isSubscribeVipPackage)
                            TextSpan(
                              text: '和《会员订阅协议》',
                              style: TextStyle(
                                color: const Color(0xFFFF8A12),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  GlobalController.instance.config
                                      .goPrivacyPageWithTitle('会员订阅协议');
                                },
                            ),
                          if (controller.payType.value == .token)
                            TextSpan(
                              text: '《积分说明》',
                              style: TextStyle(
                                color: const Color(0xFFFF8A12),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  GlobalController.instance.config
                                      .goPrivacyPageWithTitle('会员服务协议');
                                },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 58.w,
                    right: 58.w,
                    bottom: 170.h,
                    child: SizedBox(
                      height: 48.w,
                      child: ByWidgetsUtil.gradientBtn(
                        title: '同意并继续',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        borderRadius: 90,
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFFC5D06), Color(0xFFFD8507)],
                        ),
                        onClick: () {
                          controller.agreementCheckedChanged(true);
                          Get.back();
                          if (onConfirm != null) {
                            onConfirm?.call();
                          } else {
                            controller.startPay();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
