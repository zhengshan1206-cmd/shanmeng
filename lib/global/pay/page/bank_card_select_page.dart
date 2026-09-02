import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/global/other/event_tracking/event_tracking.dart';
import 'package:ling_bao/global/pay/bean/bank_pay_bank_bean.dart';
import 'package:ling_bao/global/pay/controller/bank_card_select_controller.dart';
import 'package:ling_bao/global/pay/page/bank_card_sign_web_view_page.dart';
import 'package:ling_bao/global/pay/view/bank_card_quick_pay_dialog.dart';
import 'package:ling_bao/global/ui/colors.dart';

class BankCardSelectPage extends GetView<BankCardSelectController> {
  const BankCardSelectPage({super.key});

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.back();
        },
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Image.asset(
            'assets/global/common/icon_back.png',
            width: 16.w,
            height: 16.w,
          ),
        ),
      ),
      title: ByText.text(
        text: '选择银行卡',
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        textColor: ByColor.colorF8,
      ),
    );
  }

  Widget _buildBankAvatar(BankPayBankBean bank) {
    return ClipOval(
      child: Container(
        width: 26.w,
        height: 26.w,
        color: Colors.white.withValues(alpha: 0.08),
        alignment: Alignment.center,
        child: bank.bankIcon.isNotEmpty
            ? Image.network(
                bank.bankIcon,
                width: 26.w,
                height: 26.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return ByText.text(
                    text: bank.displayIconText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    textColor: Colors.white,
                  );
                },
              )
            : ByText.text(
                text: bank.displayIconText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                textColor: Colors.white,
              ),
      ),
    );
  }

  Future<void> _handleBankTap(
    BuildContext context,
    BankPayBankBean bank,
  ) async {
    EventTracking.reportDataPoint(
      pageTag: 'Bank_choose',
      operateType: 'click',
      funcDetailTag: '',
      funcDetailImg: '',
      extra: {'backname': bank.displayName},
    );

    final String? launchUrl = await showBankCardQuickPayDialog(
      context: context,
      bank: bank,
    );
    if (launchUrl == null || launchUrl.isEmpty) {
      return;
    }
    final dynamic signResult = await Get.to(
      () => BankCardSignWebViewPage(title: '申请签约', url: launchUrl),
    );
    if (signResult == BankCardSignWebViewPage.successResult) {
      Get.back(result: BankCardSignWebViewPage.successResult);
    }
  }

  Widget _buildSelectButton() {
    return Container(
      width: 60.w,
      height: 32.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ByColor.colorG2,
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: ByText.text(
        text: '选择',
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        textColor: ByColor.colorF0,
      ),
    );
  }

  Widget _buildBankItem(BuildContext context, BankPayBankBean bank) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleBankTap(context, bank),
        child: Container(
          height: 56.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _buildBankAvatar(bank),
              SizedBox(width: 12.w),
              Expanded(
                child: ByText.text(
                  text: bank.displayName,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  textColor: ByColor.colorF8,
                ),
              ),
              _buildSelectButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ByColor.colorC1),
              strokeWidth: 2,
            ),
          ),
        );
      }
      if (controller.loadFailed.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ByText.text(
                  text: '银行卡列表加载失败',
                  fontSize: 15.sp,
                  textColor: Colors.white.withValues(alpha: 0.72),
                ),
                SizedBox(height: 16.w),
                SizedBox(
                  width: 120.w,
                  height: 40.w,
                  child: ByWidgetsUtil.gradientBtn(
                    title: '重试',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    onClick: controller.fetchBanks,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (controller.banks.isEmpty) {
        return Center(
          child: ByText.text(
            text: '暂无可选银行卡',
            fontSize: 15.sp,
            textColor: Colors.white.withValues(alpha: 0.48),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 20.w),
        child: Container(
          decoration: BoxDecoration(
            color: ByColor.colorF0,
            borderRadius: BorderRadius.circular(14.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 10.w),
                child: ByText.text(
                  text: '免输卡号快速添加',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  textColor: ByColor.colorF8,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: 6.w),
                  itemCount: controller.banks.length,
                  separatorBuilder: (_, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                    );
                  },
                  itemBuilder: (context, index) {
                    return _buildBankItem(context, controller.banks[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }
}
