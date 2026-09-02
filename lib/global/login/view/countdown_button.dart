//  description:  倒计时按钮

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/login/controller/login_controller.dart';
import 'package:ling_bao/global/ui/colors.dart';

const String _normalText = '获取验证码'; // 默认按钮文字
const String _resendAfterText = '重新获取'; // 重新获取文字
const int _normalTime = 60; // 默认倒计时时间
const double _fontSize = 16.0; // 文字大小
const double _borderRadius = 12.0; // 边框圆角

class CountDownBtn extends StatefulWidget {
  const CountDownBtn({
    super.key,
    this.getVCode,
    this.getCodeText = _normalText,
    this.resendAfterText = _resendAfterText,
    this.textColor,
    this.bgColor,
    this.fontSize = _fontSize,
    this.borderColor,
    this.borderRadius = _borderRadius,
    this.showBorder = false,
    this.onTap,
  });

  final void Function({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFaild,
  })?
  getVCode;
  final String getCodeText;
  final String resendAfterText;
  final Color? textColor;
  final Color? bgColor;
  final double? fontSize;
  final Color? borderColor;
  final double? borderRadius;
  final bool showBorder;
  final Function()? onTap;

  @override
  State<CountDownBtn> createState() => _CountDownBtnState();
}

class _CountDownBtnState extends State<CountDownBtn> {
  Timer? _countDownTimer;
  Rx<String> btnStr = _normalText.obs;
  int _countDownNum = _normalTime;
  LoginController controller = Get.put(LoginController());

  @override
  void initState() {
    super.initState();

    btnStr.value = widget.getCodeText;
  }

  /// 释放掉Timer
  @override
  void dispose() {
    _countDownTimer?.cancel();
    _countDownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onTap?.call();
        _getVCode();
      },
      child: Obx(
        () => Container(
          height: 50.h,
          width: 94.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ByColor.colorBg2,
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Text(
            btnStr.value,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: controller.vCodeBtnEnabled.value
                  ? ByColor.colorC1
                  : Colors.white.withAlphaValue(0.5),
            ),
          ),
        ),
      ),
    );

    // if (widget.getVCode == null) {
    //   return Container();
    // } else {
    //   return Consumer<LoginProvider>(builder: (context, provider, child) {
    //     return GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onTap: () => _getVCode(),
    //       child: Container(
    //         height: 45.h,
    //         width: 80.w,
    //         alignment: Alignment.center,
    //         // padding: EdgeInsets.symmetric(horizontal: 25.w),
    //         decoration: BoxDecoration(
    //           color: provider.vCodeBtnEnabled
    //               ? ByColor.TabTextColorSelected
    //               : ByColor.LoginBtnBgColor.withOpacity(0.3),
    //           borderRadius: const BorderRadius.only(
    //             topRight: Radius.circular(12.0),
    //             bottomRight: Radius.circular(12.0),
    //           ),
    //         ),
    //         child: Text(
    //           btnStr,
    //           style: TextStyle(
    //             fontSize: widget.fontSize,
    //             color: const Color(0xFFF3F3F5),
    //           ),
    //         ),
    //       ),
    //     );
    //   });
    // }
  }

  void _getVCode() {
    if (controller.vCodeBtnEnabled.value == false) return;
    _sendVCode();
  }

  /// 实际发送验证码的方法
  void _sendVCode() {
    controller.vCodeBtnEnabled.value = false;
    if (!controller.checkVCodeBtnEnabled()) return;
    controller.getVCode(
      onSuccess: (_) {
        startCountdown();
      },
      onFailed: (p0, p1) {
        controller.vCodeBtnEnabled.value = true;
      },
    );
  }

  /// 开始倒计时
  void startCountdown() {
    setState(() {
      if (_countDownTimer != null) {
        return;
      }
      btnStr.value = '${_countDownNum}s';
      _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countDownNum > 1) {
          _countDownNum--;
          btnStr.value = '${_countDownNum}s';
        } else {
          btnStr.value = widget.resendAfterText;
          _countDownNum = _normalTime;
          _countDownTimer?.cancel();
          _countDownTimer = null;
          controller.vCodeBtnEnabled.value = true;
        }
      });
    });
  }
}
