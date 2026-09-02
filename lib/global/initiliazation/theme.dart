/*
 * @Author: cold-x
 * @Date: 2025-09-12 17:04:25
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-23 09:11:00
 * @FilePath: /novel_oversea/lib/global/initiliazation/theme.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ling_bao/global/ui/colors.dart';

class AppTheme {
  // 1. 定义颜色方案（Material Design 3 核心）
  static final lightColorScheme = ColorScheme.light(
    primary: ByColor.colorC1, // 主色调（导航栏、按钮等）
    secondary: Colors.orange, // 次要色调（强调元素）
    surface: ByColor.colorBg1, // 表面色（卡片、背景）
    onPrimary: Colors.pink, // 主色调上的文本/图标颜色
    onSurface: ByColor.colorF1, // 表面色上的文本/图标颜色
  );

  // 2. 定义文本主题（全局字体样式）
  static final textTheme = TextTheme(
    bodyLarge: const TextStyle(fontSize: 18, color: Colors.black87), // 大正文
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: lightColorScheme.primary, // 关联主色调
    ), // 大标题
  );

  // 3. 全局主题配置
  static final lightTheme = ThemeData(
    colorScheme: lightColorScheme, // 颜色体系
    textTheme: textTheme, // 文本样式
    useMaterial3: true, // 启用 Material Design 3
    // 组件特定主题（可选，覆盖默认样式）
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primary,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: lightColorScheme.onPrimary, // 标题文字颜色（白色，与主色调对比）
      ),
    ),
    // 配置上下文菜单（弹出菜单）样式
    popupMenuTheme: PopupMenuThemeData(
      color: ByColor.colorF1, // 菜单背景色
      textStyle: const TextStyle(color: ByColor.colorF8), // 菜单项文本颜色
      // 其他配置（如边框、阴影等）
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColorScheme.primary, // 按钮背景色（次要色调）
      ),
    ),
  );

  static Color get primaryColor => lightColorScheme.primary;
  static Color get secondaryColor => lightColorScheme.secondary;
  static Color get surfaceColor => lightColorScheme.surface;
  static Color get onPrimaryColor => lightColorScheme.onPrimary;
  static Color get onSurfaceColor => lightColorScheme.onSurface;
}
