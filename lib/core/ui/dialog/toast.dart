/*
 * @Author: cold-x
 * @Date: 2025-09-17 16:25:26
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:21:11
 * @FilePath: /ling_bao/lib/core/ui/dialog/toast.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../global/ui/colors.dart';
import '../../util/extentions.dart';
import '../widget/by_text.dart';

enum ToastType {
  /// 默认文字
  normal,

  /// 成功提示
  success,

  /// 失败提示
  error,

  /// 警示提示
  warning,
}

class Toast {
  /// 显示文字
  static void showText({
    String text = '',
    ToastType type = ToastType.normal,
    Alignment align = Alignment.bottomCenter,
    Function()? action,
    String? clickText,
  }) {
    switch (type) {
      case ToastType.normal:
        _showToast(align: align, action: action, child: _buildText(text));
        break;
      case ToastType.success:
        _showSuccess(
          align: align,
          action: action,
          text: text,
          clickText: clickText,
        );
        break;
      case ToastType.error:
        _showError(align: align, action: action, text: text);
        break;
      case ToastType.warning:
        _showWarning(align: align, action: action, text: text);
        break;
    }
  }

  /// 显示成功
  static void _showSuccess({
    String text = '',
    String? clickText,
    required Alignment align,
    Function()? action,
  }) {
    _showToast(
      align: align,
      action: action,
      child: _showIconToast(
        child: clickText != null
            ? RichText(
                maxLines: 3,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: ByColor.colorF8,
                  ),
                  children: [
                    TextSpan(text: text),
                    TextSpan(text: ' '),
                    TextSpan(
                      text: clickText,
                      style: TextStyle(
                        color: ByColor.colorG4,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              )
            : _buildText(text),
        icon: 'assets/global/common/icon_toast_success.png',
      ),
    );
  }

  /// 显示失败
  static void _showError({
    String text = '',
    required Alignment align,
    Function()? action,
  }) {
    _showToast(
      align: align,
      action: action,
      child: _showIconToast(
        child: _buildText(text),
        icon: 'assets/global/common/icon_toast_error.png',
      ),
    );
  }

  /// 默认显示文字
  static void _showWarning({
    String text = '',
    required Alignment align,
    Function()? action,
  }) {
    _showToast(
      align: align,
      action: action,
      child: _showIconToast(
        child: _buildText(text),
        icon: 'assets/global/common/icon_toast_warning.png',
      ),
    );
  }

  /// 通用icon调用
  static Widget _showIconToast({required Widget child, required String icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, width: 24.w, height: 24.w),
        SizedBox(width: 6.w),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 280.w),
          child: child,
        ),
      ],
    );
  }

  /// 通用调用
  static void _showToast({
    required Widget child,
    required Alignment align,
    Function()? action,
  }) {
    BotToast.showCustomText(
      onlyOne: true,
      align: align,
      toastBuilder: (_) {
        return GestureDetector(
          onTap: action,
          child: Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.w),
              color: ByColor.colorF6.withAlphaValue(0.8),
              border: Border.all(
                color: ByColor.colorF0.withAlphaValue(0.04),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ByColor.colorF0.withAlphaValue(0.2), // 阴影颜色（带透明度）
                  spreadRadius: 2, // 阴影扩散半径
                  blurRadius: 2, // 阴影模糊半径
                  offset: const Offset(0, 2), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// 通用显示文字
  static Widget _buildText(String text) {
    return ByText.text(
      text: text,
      maxLines: 10,
      fontSize: 17.sp,
      fontWeight: FontWeight.w500,
      textColor: ByColor.colorF8,
      textAlign: TextAlign.center,
    );
  }
}
