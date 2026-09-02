/*
 * @Author: duncy
 * @Date: 2025-10-30 10:04:24
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-30 10:14:15
 * @FilePath: /novel_oversea/lib/global/const/const_utils.dart
 * @Description: 
 */



import 'dart:io';
import 'package:flutter/material.dart';

class ConstUtils {

  static double getNavigationHeight() {
    return Platform.isIOS ? 44 : kToolbarHeight;
  }
}