import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/view/byhy_base_web_view.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';

class BankCardAgreementConfirmDialog extends StatelessWidget {
  const BankCardAgreementConfirmDialog({
    super.key,
    required this.agreementUrl,
    this.onConfirm,
  });

  final String agreementUrl;
  final Future<void> Function()? onConfirm;

  bool get _canOpenAgreement => agreementUrl.trim().isNotEmpty;

  void _openAgreement() {
    if (!_canOpenAgreement) {
      return;
    }
    Get.to(() => ByHyBaseWebView(title: '一键绑卡协议', url: agreementUrl));
  }

  Future<void> _handleConfirm() async {
    Get.back();
    await onConfirm?.call();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ByText.text(
                          text: '请阅读并同意',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          textColor: const Color(0xFF8D7E61),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _canOpenAgreement ? _openAgreement : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: ByText.text(
                              text: '《一键绑卡协议》',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              textColor: _canOpenAgreement
                                  ? const Color(0xFFFF8A12)
                                  : const Color(0xFFC9B998),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 58.w,
                    right: 58.w,
                    bottom: 176.h,
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
                        onClick: _handleConfirm,
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
