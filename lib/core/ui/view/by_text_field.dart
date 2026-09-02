/*
 * @Author: cold-x
 * @Date: 2025-06-17 15:49:41
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:30:23
 * @FilePath: /ling_bao/lib/core/ui/view/by_text_field.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../global/ui/colors.dart';

class ByTextField extends StatelessWidget {
  const ByTextField({
    super.key,
    this.hintText = '',
    this.change,
    this.complete,
    this.align = TextAlign.start,
    this.maxLines = 1,
    this.maxLength,
    this.inputType = TextInputType.text,
    this.textColor = ByColor.colorF1,
    this.fontSize,
    this.cursorColor,
    this.inputFormatters,
    this.focusNode,
    this.scrollPhysics,
    this.readOnly = false,
    this.controller,
  });

  final String? hintText;
  final Function(String)? change;
  final Function()? complete;
  final TextEditingController? controller;
  final int? maxLines;
  final TextAlign? align;
  final Color? textColor;
  final Color? cursorColor;
  final double? fontSize;
  final TextInputType? inputType;
  final int? maxLength;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool? readOnly;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return TextField(
      selectionControls: MaterialTextSelectionControls(),
      textAlign: align!,
      maxLines: maxLines,
      focusNode: focusNode,
      readOnly: readOnly!,
      autofocus: false,
      cursorColor: cursorColor,
      scrollPhysics: scrollPhysics,
      keyboardType: inputType,
      maxLength: maxLength ?? 999999999,
      inputFormatters: inputFormatters ?? [],
      textInputAction: TextInputAction.done,
      style: TextStyle(color: textColor, fontSize: 14.sp),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 3.w, left: 3.w),
        isCollapsed: true,
        border: InputBorder.none,
        hintText: hintText,
        counterText: '',
        hintStyle: TextStyle(
          fontSize: fontSize ?? 14.sp,
          fontWeight: FontWeight.normal,
          color: ByColor.colorF2,
        ),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: ByColor.colorF1,
        ),
      ),
      onChanged: (String value) {
        change?.call(value);
      },
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        complete?.call();
      },
      controller: controller ?? TextEditingController(),
    );
  }
}
