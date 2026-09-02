/*
 * @Author: duncy
 * @Date: 2026-01-26 11:34:58
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-26 10:25:35
 * @FilePath: /novel_oversea/lib/global/initiliazation/app_life_circle.dart
 * @Description: 
 */

// 自定义全局监听类
import 'package:flutter/material.dart';
import 'package:ling_bao/core/common/event/common_event.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  // 单例模式，全局唯一
  static final AppLifecycleObserver _instance =
      AppLifecycleObserver._internal();
  factory AppLifecycleObserver() => _instance;
  AppLifecycleObserver._internal();

  // 标记是后台进入前台
  bool _isBackGroundResume = false;

  void _notifyVisibleVideoResume() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VisibilityDetectorController.instance.notifyNow();
      eventBus.fire(const ResumeVideoEvent());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print('app周期:______$state');
    if (state == AppLifecycleState.resumed) {
      // print("______全局监听：App 回到前台");
      if (_instance._isBackGroundResume) {
        _notifyVisibleVideoResume();
      }
      _instance._isBackGroundResume = false;
      // 全局前台逻辑（如重新初始化推送、定位）
    } else if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      // print("______全局监听：App 进入后台");
      _instance._isBackGroundResume = true;
      // 全局后台逻辑（如停止定位、保存用户状态）
    }
  }
}
