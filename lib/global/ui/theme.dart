/*
 * @Author: cold-x
 * @Date: 2025-06-03 11:49:04
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-09 13:40:48
 * @FilePath: /novel_oversea/lib/global/ui/theme.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

EdgeInsets get safeAreaEdgeInsets => Get.mediaQuery.viewPadding;

double safeAreaTopDistance(double distance) =>
    safeAreaEdgeInsets.top + distance;

double safeAreaBottomDistance(double distance) =>
    safeAreaEdgeInsets.bottom + distance;

