// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ByColor {
  /*
    主题色
  */
  ///品牌色、交互主色、选中色
  static const colorC1 = Color(0xFFFD2B54);

  /*
    背景色
  */
  ///全局背景色
  static const colorBg1 = Color(0xFF0F0F12);

  ///背景色上叠加的更高层级按钮/模块等
  static const colorBg2 = Color(0xFF1E1F24);

  ///
  static const color2E3038 = Color(0xFF2E3038);

  ///模块背景色
  static const colorBg3 = Color.fromRGBO(255, 255, 255, 0.08);

  static const colorBg4 = Color.fromRGBO(255, 255, 255, 0.1);

  ///背景色上叠加的更高层级按钮/
  /*
    线条
  */
  static const colorL1 = Color(0xFF26272E);

  ///分割线

  /*
    文本颜色
  */
  static const colorF0 = Color(0xFFFFFFFF);
  static const colorF1 = Color(0xFFDDEAF0);

  ///重要文字、大标题
  static const colorF2 = Color(0xFF9EAFBC);

  ///创建专业版字体
  static const colorPro = Color(0xFF27EEFB);

  ///次要文字
  static const colorF3 = Color(0xFF4D4E56);

  static const colorF4 = Color(0xFF416606);

  static const colorF5 = Color(0xFFB8E44A);

  static const colorF6 = Color(0xFFEBF8FF);

  static const colorF7 = Color(0xFF09090B);

  static const colorF8 = Color(0xFF050601);

  ///说明文字/禁用文字

  /*
    功能颜色
  */
  static LinearGradient colorG1() {
    return LinearGradient(
      colors: [ByColor.colorC1, Color(0xFFFF6180)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  static LinearGradient colorVIP() {
    return const LinearGradient(
      colors: [Color(0xFF82D7FF), Color(0xFFBFE0FF), Color(0xFFDCC8FF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  ///渐变色按钮装饰
  static const colorG2 = Color(0xFF2C71FA);

  ///点缀色蓝
  static const colorG3 = Color(0xFFFFAA2B);

  ///点缀色橙
  static const colorG4 = Color(0xFFFE5024);

  ///按钮背景颜色
  static const colorB1 = Color(0xFF2E3038);

  ///危险、报错、一级提示色

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
  }) => LinearGradient(colors: [colorStart, colorEnd], begin: begin, end: end);

  /// 线性渐变装饰器
  static LinearGradient linearGradientMultiple({
    List<Color>? colors,
    List<double>? stops,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) => LinearGradient(
    colors:
        colors ??
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
  static LinearGradient linearGradientMultipleWithColorsString({
    required String colorsString,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) {
    final colorsStr = colorsString.split(",");
    final colors = colorsStr.map((e) => ByColor.hexToColor(e)).toList();
    final step = 1 / (colors.length - 1);
    final List<double> stops = colors.map((e) {
      return step * (colors.indexOf(e));
    }).toList();
    return LinearGradient(colors: colors, stops: stops, begin: begin, end: end);
  }

  /// 线性渐变装饰器
  static LinearGradient linearGradientMultipleWithHexaColorsString({
    required String colorsString,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) {
    final colorsStr = colorsString.split(",");
    final colors = colorsStr.map((e) => ByColor.hexaToColor(e)).toList();
    final step = 1 / (colors.length - 1);
    final List<double> stops = colors.map((e) {
      return step * (colors.indexOf(e));
    }).toList();
    return LinearGradient(colors: colors, stops: stops, begin: begin, end: end);
  }
}
