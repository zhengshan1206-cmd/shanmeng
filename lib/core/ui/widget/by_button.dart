/*
 * @Author: cold-x
 * @Date: 2025-09-12 16:50:08
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:22:03
 * @FilePath: /ling_bao/lib/core/ui/widget/by_button.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';

import '../../../global/initiliazation/theme.dart';
import '../../../global/ui/colors.dart';

class ByButton {
  static Widget button({
    VoidCallback? onPressed,
    String? title,
    Color? backgroundColor,
    double? fontSize,
    Color? titleColor,
    Color? borderColor,
    FontWeight? fontWeight,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) {
    return GestureDetector(
      onTap: () => onPressed?.call(),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.primaryColor,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: ByButton.buttonTitle(
            title: title,
            fontSize: fontSize,
            titleColor: titleColor,
            fontWeight: fontWeight,
          ).animate().fade().scale(duration: 200.ms, curve: Curves.easeOut),
        ),
      ),
    );
  }

  static Widget buttonWidget({
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? borderColor,
    FontWeight? fontWeight,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(0.0),
    Widget? child,
  }) {
    return ElevatedButton(
      onPressed: () => onPressed?.call(),
      style: ByButton.getButtonStyle(
        backgroundColor: backgroundColor ?? Colors.transparent,
        padding: padding,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding,
        child: Center(child: child),
      ),
    );
  }

  static Widget textButton({
    VoidCallback? onPressed,
    String? title,
    Color? backgroundColor,
    double? fontSize,
    Color? titleColor,
    FontWeight? fontWeight,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) {
    return SizedBox(
      height: 48.w,
      child: TextButton(
        onPressed: () => onPressed?.call(),
        style: ByButton.getButtonStyle(
          backgroundColor: backgroundColor,
          padding: padding,
          borderRadius: borderRadius,
        ),
        child: ByButton.buttonTitle(
          title: title,
          fontSize: fontSize,
          titleColor: titleColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  static Widget floatingButton({
    VoidCallback? onPressed,
    String? title,
    Color? backgroundColor,
    double? fontSize,
    Color? titleColor,
    FontWeight? fontWeight,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: () => onPressed?.call(),
        style: ByButton.getButtonStyle(
          backgroundColor: backgroundColor,
          padding: padding,
          borderRadius: borderRadius,
        ),
        child: ByButton.buttonTitle(
          title: title,
          fontSize: fontSize,
          titleColor: titleColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  static Widget outlinedButton({
    VoidCallback? onPressed,
    String? title,
    Color? backgroundColor,
    double? fontSize,
    Color? titleColor,
    Color? borderColor,
    FontWeight? fontWeight,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) {
    return SizedBox(
      child: OutlinedButton(
        onPressed: () => onPressed?.call(),
        style: ByButton.getButtonStyle(
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          padding: padding,
          borderRadius: borderRadius,
        ),
        child: ByButton.buttonTitle(
          title: title,
          fontSize: fontSize,
          titleColor: titleColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  static Widget iconButton({
    VoidCallback? onPressed,
    required Widget icon,
    String? title,
    Color? backgroundColor,
    double? fontSize,
    Color? titleColor,
    double? size,
    FontWeight? fontWeight,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) {
    return SizedBox(
      child: TextButton.icon(
        onPressed: () => onPressed?.call(),
        style: ByButton.getButtonStyle(
          backgroundColor: backgroundColor,
          padding: padding,
          borderRadius: borderRadius,
        ),
        icon: SizedBox(
          width: size ?? 20,
          height: size ?? 20,
          child: Center(child: icon),
        ),
        label: ByButton.buttonTitle(
          title: title,
          fontSize: fontSize,
          titleColor: titleColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  ///按钮样式
  static ButtonStyle getButtonStyle({
    Color? backgroundColor,
    Color? borderColor,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
      ),
      side: borderColor != null
          ? BorderSide(color: borderColor, width: 1)
          : null,
      shadowColor: Colors.black12,
      elevation: 2,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      padding: padding,
    );
  }

  ///按钮标题
  static Widget buttonTitle({
    double? fontSize,
    Color? titleColor,
    FontWeight? fontWeight,
    String? title,
  }) {
    return ByText.text(
      text: title ?? '',
      fontSize: fontSize ?? 17.sp,
      maxLines: 1,
      fontWeight: fontWeight ?? FontWeight.w600,
      textColor: titleColor ?? ByColor.colorF8,
    );
  }
}
