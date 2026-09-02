import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../global/ui/colors.dart';
import '../widget/by_text.dart';

class LoadingDialog {
  static final LoadingDialog _instance = LoadingDialog._internal();
  factory LoadingDialog() => _instance;
  LoadingDialog._internal();

  bool _isShowing = false;

  // 显示加载对话框
  void show({String? message}) {
    if (_isShowing) return;

    _isShowing = true;
    showDialog(
      context: Get.context!,
      barrierDismissible: false, // 禁止点击背景关闭
      builder: (context) => PopScope(
        canPop: false, // 禁止返回键关闭
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 134.w,
                height: 134.w,
                child: LoadingView(loadingText: message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 隐藏加载对话框
  void dismiss() {
    if (!_isShowing) return;
    Get.back();
    _isShowing = false;
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.loadingText, this.bgColor});

  final String? loadingText;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134.w,
      height: 134.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.w),
        color: bgColor ?? ByColor.colorBg1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 12.w),
          SizedBox(
            width: 58.w,
            height: 58.w,
            child: Stack(
              children: [
                const LoadingIndicator(
                  indicatorType: Indicator.circleStrokeSpin,
                  colors: [ByColor.colorC1],
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                  pathBackgroundColor: Colors.transparent,
                ),
                Center(
                  child: Image.asset(
                    'assets/icon.png',
                    width: 32.w,
                    height: 32.w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.w),
          ByText.text(
            text: loadingText ?? '',
            fontSize: 13.sp,
            textColor: ByColor.colorF1,
          ),
        ],
      ),
    );
  }
}
