import 'dart:io';

import 'package:flutter/gestures.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/service/animate/scale_transition_widget.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/pay/bean/vip_type_bean.dart';
import 'package:ling_bao/global/pay/controller/pay_controller.dart';
import '../../../global/ui/colors.dart';

class PayRetainDialog extends StatefulWidget {
  const PayRetainDialog({super.key, required this.type});

  final int type;

  @override
  State<PayRetainDialog> createState() => _PayRetainDialogState();
}

class _PayRetainDialogState extends State<PayRetainDialog> {
  late final PayController controller;
  late VipTypeBean bean;
  late List<Map<String, dynamic>> _payList;
  late int _selectedPayIndex;

  @override
  void initState() {
    super.initState();
    final bool isRegister = Get.isRegistered<PayController>();
    if (isRegister) {
      controller = Get.find<PayController>();
    } else {
      controller = Get.put(PayController(), tag: 'retain');
    }
    if (widget.type == 1) {
      bean = controller.payManager.payData.obList.first;
    } else {
      bean = controller.payManager.payData.vipInterceptList.first;
    }
    _payList = controller.payManager.getVipPayMethodList(bean: bean);
    try {
      controller.payManager.currentPayMethod = bean.payTypes.split(',').first;
    } catch (e) {
      controller.payManager.currentPayMethod = Platform.isAndroid
          ? "wxpay"
          : "apple";
    }
    _selectedPayIndex = controller.payManager.getPayMethodIndex(_payList);
  }

  Widget _buildPayMethodIcon(Map<String, dynamic> payMethod, Color iconColor) {
    final String? icon = payMethod['icon'] as String?;
    if (icon != null && icon.isNotEmpty) {
      return Image.asset(icon, width: 16, height: 16);
    }
    final IconData? iconData = payMethod['iconData'] as IconData?;
    if (iconData != null) {
      return Icon(iconData, size: 16, color: iconColor);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPayMethodItem({
    required Map<String, dynamic> payMethod,
    required bool isSelected,
    required Color mainColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _buildPayMethodIcon(payMethod, mainColor),
            const SizedBox(width: 4),
            ByText.text(
              text: payMethod['payLabel'] ?? payMethod['payName'] ?? '',
              textColor: mainColor,
            ),
            const SizedBox(width: 4),
            Image.asset(
              'assets/pay/radio_${isSelected ? 'selected' : 'unselected'}.png',
              width: 16,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 带波纹的付费页样式
  Widget _buildRetainDialog() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: ByScreenUtils.screenHeight,
        color: ByColor.colorBg1.withAlphaValue(0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ByScreenUtils.topSafeHeight),
            _buildCloseBtn(paddingLeft: true),
            SizedBox(height: 46.w),
            Container(
              height: 530.w,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pay/icon_pay_retain_bg.png'),
                ),
              ),
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  ByText.text(
                    text: bean.title,
                    fontSize: 40.sp,
                    textColor: Color(0xFFCF5100),
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ByText.text(
                        text: '￥',
                        fontSize: 16.sp,
                        textColor: Color(0xFFFA3E05),
                        fontWeight: .bold,
                      ),
                      ByText.text(
                        text: bean.money,
                        fontSize: 48.sp,
                        textColor: Color(0xFFFA3E05),
                        fontWeight: .bold,
                      ),
                    ],
                  ),

                  ByWidgetsUtil.commonRichText(
                    texts: [
                      TextSpan(text: '原价'),
                      TextSpan(
                        text: '￥${bean.crossedMoney}',
                        style: TextStyle(decoration: .lineThrough),
                      ),
                    ],
                    textColor: Color(0x99AA5B16),
                  ),
                  SizedBox(height: 5.w),
                  SizedBox(
                    height: 20.w,
                    child: ByText.text(
                      text: bean.des,
                      fontSize: 13.sp,
                      textColor: Color(0xFFAA5B16).withAlphaValue(0.5),
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 152.w),

                  /// 开通
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 48.w,
                          width: 260.w,
                          child: ScaleTransitionWidget(
                            min: 0.95,
                            max: 1,
                            period: 900,
                            child: ByWidgetsUtil.gradientBtn(
                              title: controller.getPackageButtonText(
                                bean: bean,
                              ),
                              fontSize: 18.sp,
                              fontWeight: .w700,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFC5D06), Color(0xFFFD8507)],
                              ),
                              onClick: () {
                                final String? payMethodKey = _payList.isEmpty
                                    ? null
                                    : _payList[_selectedPayIndex]["payNameKey"];
                                controller.startPay(
                                  bean: bean,
                                  payMethodKey: payMethodKey,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 56.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: SizedBox(height: 56.w, child: _buildPayWay()),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Obx(
              () => _RetainAgreementView(
                selected: controller.agreementChecked.value,
                show: controller.user.isAudit(),
                showMemberSubscribeAgreement: (bean.isSubscribe ?? 0) == 1,
                tap: () {
                  controller.agreementCheckedChanged(
                    !controller.agreementChecked.value,
                  );
                },
              ),
            ),
            SizedBox(height: 8.w + max(12.w, ByScreenUtils.bottomSafeHeight)),
          ],
        ),
      ),
    );
  }

  ///支付方式
  Widget _buildPayWay() {
    if (_payList.isEmpty) {
      return const SizedBox.shrink();
    }

    const Color mainColor = Color(0xFFAA5B16);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 30.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ByText.text(text: '支付方式', textColor: mainColor),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(_payList.length, (index) {
                      final Map<String, dynamic> payMethod = _payList[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _payList.length - 1 ? 0 : 8,
                        ),
                        child: _buildPayMethodItem(
                          payMethod: payMethod,
                          isSelected: _selectedPayIndex == index,
                          mainColor: mainColor,
                          onTap: () {
                            if (_selectedPayIndex == index) {
                              return;
                            }
                            setState(() {
                              _selectedPayIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 关闭按钮
  Widget _buildCloseBtn({bool? paddingLeft = false}) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(top: 12, left: paddingLeft! ? 12.w : 0),
            decoration: BoxDecoration(
              color: ByColor.colorF8.withAlphaValue(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              "assets/global/common/btn_close.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildRetainDialog();
  }
}

class _RetainAgreementView extends StatelessWidget {
  const _RetainAgreementView({
    this.selected = false,
    this.show = true,
    this.showMemberSubscribeAgreement = false,
    this.tap,
  });

  final bool selected;
  final bool show;
  final bool showMemberSubscribeAgreement;
  final VoidCallback? tap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: tap,
      child: Container(
        constraints: BoxConstraints(minHeight: 36.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.w),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (show)
                Image.asset(
                  selected
                      ? "assets/pay/radio_selected.png"
                      : "assets/pay/radio_unselected.png",
                  fit: BoxFit.fill,
                  width: 16.w,
                  height: 16.w,
                ),
              SizedBox(width: 4.w),
              Flexible(
                child: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '已同意',
                        style: TextStyle(
                          fontSize: 12,
                          color: ByColor.colorF3,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: " 《会员服务协议》",
                        style: const TextStyle(
                          fontSize: 12,
                          color: ByColor.colorF1,
                          height: 1.2,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            GlobalController.instance.config
                                .goPrivacyPageWithTitle("会员服务协议");
                          },
                      ),
                      if (showMemberSubscribeAgreement)
                        const TextSpan(
                          text: "和",
                          style: TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF3,
                            height: 1.2,
                          ),
                        ),
                      if (showMemberSubscribeAgreement)
                        TextSpan(
                          text: "《会员订阅协议》",
                          style: const TextStyle(
                            fontSize: 12,
                            color: ByColor.colorF1,
                            height: 1.2,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              GlobalController.instance.config
                                  .goPrivacyPageWithTitle("会员订阅协议");
                            },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
