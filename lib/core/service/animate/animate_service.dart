/*
 * @Author: duncy
 * @Date: 2025-09-24 12:04:03
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-24 13:49:53
 * @FilePath: /novel_oversea/lib/core/service/animate/animate_service.dart
 * @Description: 
 */


import 'package:flutter/material.dart';

/// 通用动画服务类（支持double类型动画值）
class AnimationService {
  final TickerProvider vsync; // 提供vsync（通常来自StatefulWidget）
  final Duration duration; // 动画时长
  final Curve curve; // 动画曲线

  late AnimationController _controller;
  late Animation<double> _animation;

  // 暴露动画对象供UI监听
  Animation<double> get animation => _animation;

  // 构造函数：初始化参数
  AnimationService({
    required this.vsync,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.elasticOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    // 初始化控制器
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    // 初始化动画（可根据需求自定义动画曲线和值范围）
    _animation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
  }

  // 开始动画
  void start({bool reverse = false}) {
    if (reverse) {
      _controller.reverse(from: 1.0);
    } else {
      _controller.forward(from: 0.0);
    }
  }

  // 暂停动画
  void pause() => _controller.stop();

  // 反向播放
  void reverse() => _controller.reverse();

  // 重复播放
  void repeat({bool reverse = true}) => _controller.repeat(reverse: reverse);

  // 释放资源（必须调用）
  void dispose() => _controller.dispose();
}

/// 颜色动画服务类
class ColorAnimationService extends AnimationService {
  late Animation<Color?> _colorAnimation;

  Animation<Color?> get colorAnimation => _colorAnimation;

  ColorAnimationService({
    required super.vsync,
    super.duration,
    super.curve,
    required Color begin,
    required Color end,
  }) {
    _colorAnimation = ColorTween(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
  }
}