
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ByHyColorUtil {
  static const mainTextColor = Color(0xFF000000);
  static const tabTextColorSelected = Color(0xFF5B4BF7);
  static const tabTextColorMarquee = Color(0xFFEA3B75);
  static const homeHotAuthTitleBg = Color(0xFFDBE4FF);
  static const homeHotAuthNumberColor = Color(0xFFFF1034);
  static const homeHotAuthIncomeColor = Color(0xFFFF8C39);
  static const homeHotAuthBtnBgColor = Color(0xFFFFCC3B);
  static const homeHotAuthRankGradientColorStart = Color(0xFFFF3838);
  static const homeHotAuthRankGradientColorEnd = Color(0xFFFF3EAB);
  static const loginTextfieldTextColor = Color(0xFF101E48);
  static const loginBtnBgColor = Color(0xFF5B4BF7);
  static const commonPageBgColor = Color(0xFFF8FAFB);
  static const commonTextColor = Color(0xFF0B1843);
  static const bandedWordsColor = Color(0xFFF62B60);

  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF000000);
  static const commonInputBgColor = Color(0xFFF3F3F5);
  static const purchaseBorderColor = Color(0xFFFFE8B6);
  static const purchaseTagNewBgColor = Color(0xFFFF3B4F);
  static const purchaseDialogTimeBgColor = Color(0xFFF4593F);
  static const purchasePriceTextColor = Color(0xFF805008);
  static const purchasePriceDescColor = Color(0xFF7A4502);

  static const color121634 = Color(0xff121634);
  static const colorF8FAFB = Color(0xffF8FAFB);

  static const color202026 = Color(0xff202026);

  static const color4E4C4B = Color(0xff4E4C4B);

  static const colorFAE3C8 = Color(0xffFAE3C8);

  static const colorFFCB86 = Color(0xffFFCB86);

  static const colorFFEEDA = Color(0xffFFEEDA);

  static const color131420 = Color(0xff131420);

  static const colorF4F7F8 = Color(0xffF4F7F8);

  static const colorF3F5F9 = Color(0xffF3F5F9);

  static const colorEAEEFF = Color(0xffEAEEFF);

  static const color4A1F00 = Color(0xff4A1F00);

  static const colorFF8902 = Color(0xffFF8902);

  static const color67441E = Color(0xff67441E);

  static const color0B1843 = Color(0xff0B1843);

  static const colorF0F2F9 = Color(0xffF0F2F9);

  static const colorF9FAFF = Color(0xffF9FAFF);

  static const colorF4F6FF = Color(0xffF4F6FF);

  static const color81899F = Color(0xff81899F);

  static const colorF4F8F9 = Color(0xffF4F8F9);

  static const color3753FF = Color(0xff3753FF);

  static const colorFBFCFD = Color(0xffFBFCFD);

  static Color hexToColor(String hex) {
    hex = hex.replaceAll("#", ""); // 去掉 #
    if (hex.length == 6) {
      hex = "FF$hex"; // 如果没有透明度，默认添加 FF 作为透明度
    }
    return Color(int.parse("0x$hex"));
  }

  static Color hexaToColor(String hex) {
    hex = hex.replaceAll("#", ""); // 去掉 #
    if (hex.length == 6) {
      hex = "FF$hex"; // 如果没有透明度，默认添加 FF 作为透明度
    } else {
      hex = "${hex.substring(6)}${hex.substring(0, 6)}";
    }
    return Color(int.parse("0x$hex"));
  }

  /// 线性渐变装饰器
  static LinearGradient lineareGradient({
    required Color colorStart,
    required Color colorEnd,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) =>
      LinearGradient(
        colors: [
          colorStart,
          colorEnd,
        ],
        begin: begin,
        end: end,
      );

  /// 线性渐变装饰器
  static LinearGradient lineareGradientMultiple({
    List<Color>? colors,
    List<double>? stops,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) =>
      LinearGradient(
        colors: colors ??
            [
              const Color(0xFF4BB1FF),
              const Color(0xFFE6F1FC),
              const Color(0xFFFBB1FF),
            ],
        stops: stops ?? [0, 0.5, 1],
        begin: begin,
        end: end,
      );

  /// 线性渐变装饰器
  static LinearGradient lineareGradientMultipleWithColorsString({
    required String colorsString,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) {
    final colorsStr = colorsString.split(",");
    final colors = colorsStr.map((e) => ByHyColorUtil.hexToColor(e)).toList();
    final step = 1 / (colors.length - 1);
    final List<double> stops = colors.map((e) {
      return step * (colors.indexOf(e));
    }).toList();
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  /// 线性渐变装饰器
  static LinearGradient lineareGradientMultipleWithHexaColorsString({
    required String colorsString,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) {
    final colorsStr = colorsString.split(",");
    final colors = colorsStr.map((e) => ByHyColorUtil.hexaToColor(e)).toList();
    final step = 1 / (colors.length - 1);
    final List<double> stops = colors.map((e) {
      return step * (colors.indexOf(e));
    }).toList();
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  /// hex颜色设置
  static Color hexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
