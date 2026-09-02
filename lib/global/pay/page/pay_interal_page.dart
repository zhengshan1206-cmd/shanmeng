import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/global/pay/controller/pay_controller.dart';
import 'package:ling_bao/global/pay/page/pay_center_page.dart';

import '../../../core/ui/page/base_page.dart';
import '../../../core/ui/widget/by_text.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../ui/colors.dart';
import '../bean/integral_pay_list_bean.dart';

// ignore: must_be_immutable
class MemberWordsPackagePage extends BasePage {
  MemberWordsPackagePage({
    super.key,
    this.isBackHome = false,
    this.source = 'unknown',
  });

  final bool? isBackHome;
  final String? source;

  @override
  String get title => '会员中心';

  @override
  bool get hasAppBar => false;

  @override
  PayController get controller => Get.put(PayController());

  ///关闭按钮
  Widget _buildCloseButton() {
    return Positioned(
      top: 12,
      right: 0,
      child: GestureDetector(
        onTap: () {
          controller.closePayPage();
        },
        child: Container(
          width: 48,
          height: 32,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/global/common/btn_close.png',
            width: 32,
            height: 32,
          ),
        ),
      ),
    );
  }

  ///会员中心主体
  Widget _buildMemberCenterBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.w),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
          height: 32.w,
          child: Row(
            children: [
              ByText.text(text: '灵宝值充值', fontSize: 18.sp, fontWeight: .bold),
              ByText.text(
                text:
                    '(剩余灵宝值： ${controller.user.userInfoBean.value?.integral ?? 0})',
                fontSize: 16.sp,
                textColor: ByColor.colorF2,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.w),
        Obx(() {
          final itemCount =
              controller.payManager.payData.wordsPackageList.length;
          if (itemCount == 0) {
            return SizedBox(
              height: 125.h,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ByColor.colorC1),
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final rowCount = (itemCount / 3).ceil();
          return Container(
            height: 125.h * rowCount,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: _buildWordList(),
          );
        }),
        SizedBox(height: 10.h),
        if (Platform.isAndroid) _buildPayWay(),
        _buildBottomFloating(),
        SizedBox(height: ByScreenUtils.bottomSafeHeight),
      ],
    );
  }

  ///字数包支付列表item
  Widget _buildWordPackageItem(int index, String type) {
    final IntegralPayListBean vipTypeBean =
        controller.payManager.payData.wordsPackageList[index];

    return GestureDetector(
      onTap: () {
        controller.switchVipListCurrent(index);
      },
      child: Obx(() {
        final isSelected = controller.payManager.selectIndex.value == index;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isSelected
                ? LinearGradient(colors: [Color(0xFF6438A7), Color(0xFF662DDA)])
                : null,
            color: isSelected ? null : const Color(0x14FFFFFF),
            border: Border.all(
              width: 2,
              color: isSelected ? Color(0xFFF895FF) : Colors.transparent,
            ),
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 14.h, left: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/profile/icon_profile_credits.png',
                      height: 24.w,
                    ),
                    SizedBox(height: 4.h),
                    ByText.text(
                      text: vipTypeBean.integral.toString(),
                      textColor: Color(0xFFF5B768),
                      fontWeight: .bold,
                    ),
                    SizedBox(height: 12.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '¥ ',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: ByColor.colorF1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: vipTypeBean.money,
                            style: TextStyle(
                              fontSize: 30.sp,
                              color: ByColor.colorF0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // if (vipTypeBean.isDefault == 1) _builditemLabel(vipTypeBean),
            ],
          ),
        );
      }),
    );
  }

  ///字数包支付列表
  Widget _buildWordList() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      shrinkWrap: true,
      itemCount: controller.payManager.payData.wordsPackageList.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 111 / 125,
      ),
      itemBuilder: (context, index) {
        return _buildWordPackageItem(index, 'Word');
      },
    );
  }

  ///支付方式
  Widget _buildPayWay() {
    return Obx(() {
      final payList = controller.payManager.wordPackagePayMethodBeans;
      final payIndex =
          controller.payManager.currentWordPackagePayMethodIndex.value;

      if (payList.isEmpty) {
        return const SizedBox.shrink();
      }

      if (payIndex >= payList.length) {
        return const SizedBox.shrink();
      }

      final payMethodBeans = payList[payIndex];
      final isWechat = payMethodBeans['payName'] == '微信支付';
      final isAlipay = payMethodBeans['payName'] == '支付宝支付';
      final hasWechat = payList.any((item) => item['payName'] == '微信支付');
      final hasAlipay = payList.any((item) => item['payName'] == '支付宝支付');

      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 38.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ByText.text(text: '支付方式', textColor: ByColor.colorF0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!hasWechat || isWechat) return;
                      controller.payManager.switchPayMethod(0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/pay/wechat_pay.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 4),
                          ByText.text(text: '微信', textColor: ByColor.colorF1),
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/pay/radio_${isWechat ? 'selected' : 'unselected'}.png',
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!hasAlipay || isAlipay) return;
                      controller.payManager.switchPayMethod(1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/pay/ali_pay.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 4),
                          ByText.text(text: '支付宝', textColor: ByColor.colorF1),
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/pay/radio_${isAlipay ? 'selected' : 'unselected'}.png',
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  ///底部悬浮
  Widget _buildBottomFloating() {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Obx(() {
            // 检查列表是否为空
            if (controller.payManager.payData.wordsPackageList.isEmpty) {
              return const SizedBox.shrink();
            }

            // 检查索引是否有效
            if (controller.payManager.currentWordPackagePayMethodIndex.value >=
                controller.payManager.payData.wordsPackageList.length) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                controller.startPay();
              },
              child: Container(
                height: 48.w,
                alignment: .center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/profile/btn_intergral_charge.png',
                    ),
                  ),
                ),
                child: ByText.text(
                  text: controller.getPackageButtonText(),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
          SizedBox(height: 12.w),
          Obx(
            () => controller.getCurrentDataList().isEmpty
                ? SizedBox(height: 20.w)
                : AgreementView(
                    show: controller.user.isAudit(),
                    selected: controller.agreementChecked.value,
                    tap: () {
                      controller.agreementCheckedChanged(
                        !controller.agreementChecked.value,
                      );
                    },
                  ),
          ),
          SizedBox(height: ByScreenUtils.bottomSafeHeight + 16.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: buildBody(context),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        controller.closePayPage();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8451E5), Color(0xFF43346B)],
                    ),
                  ),
                  child: Stack(
                    children: [_buildMemberCenterBody(), _buildCloseButton()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
