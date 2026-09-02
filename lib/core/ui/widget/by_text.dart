/*
 * @Author: duncy
 * @Date: 2025-12-16 14:35:11
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 16:47:10
 * @FilePath: /ling_bao/lib/core/ui/widget/by_text.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ByText {
  /// 通用Text组件
  static Text text({
    String? fontFamily,
    required String text,
    double? fontSize,
    FontWeight? fontWeight = FontWeight.normal,
    TextAlign? textAlign,
    Color? textColor,
    int? maxLines,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? decorationColor,
    double? height,
    double? decorationThickness,
    Color? bgColor,
  }) {
    return Text(
      // text.loc,
      text,
      textAlign: textAlign,
      maxLines: maxLines ?? 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        height: height,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        fontStyle: fontStyle ?? FontStyle.normal,
        fontSize: fontSize ?? 14.sp,
        decoration: decoration ?? TextDecoration.none,
        decorationThickness: decorationThickness,
        color: textColor ?? Colors.white,
        decorationColor: decorationColor ?? Colors.white.withValues(alpha: 0.5),
        backgroundColor: bgColor ?? Colors.transparent,
      ),
    );
  }
}
