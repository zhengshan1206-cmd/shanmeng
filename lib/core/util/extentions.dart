/*
 * @Author: cold-x
 * @Date: 2025-09-16 16:51:45
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-22 11:23:56
 * @FilePath: /novel_oversea/lib/core/util/extentions.dart
 * @Description: 
 */


import 'dart:convert';
import 'dart:ui';
import 'package:get/get.dart';

extension LocaleString on String {
  String get loc {
    if(isEmpty) return this;
    try {
      if (this == '') return this;
      return tr;
    } catch (e) {
      return this;
    }
  }
}

extension ColorExtensions on Color {
  // 生成具有指定透明度的新颜色（使用 withValues）
  Color withAlphaValue(double alpha) {
    return withAlpha((alpha.clamp(0.0, 1.0) * 255).round());
  }
}

extension MapExtension on Map<String, dynamic> {
  void setIfNotNull({required dynamic value, required String key}) {
    if (value != null) {
      this[key] = value;
    }
  }

  Map<String, String> convertMap(){
    return Map.fromEntries(
        entries
            .where((entry) => entry.value != null)
            .map((entry) => MapEntry(entry.key, entry.value is String ? entry.value : jsonEncode(entry.value)))
    );
  }
}

extension OptionalEmptyExpression on String? {
  bool isEmptyString() {
    return isEmpty(this);
  }

  bool isNotEmptyString() {
    return isNotEmpty(this);
  }

  static bool isEmpty(String? text) {
    if (text == null) {
      return true;
    }
    return text.isEmpty;
  }

  static bool isNotEmpty(String? text) {
    if (text == null) {
      return false;
    }
    return text.isNotEmpty;
  }
}