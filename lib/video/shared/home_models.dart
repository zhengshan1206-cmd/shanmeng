/*
 * @Author: duncy
 * @Date: 2026-04-02 14:08:50
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 18:57:16
 * @FilePath: /ling_bao/lib/video/shared/home_models.dart
 * @Description: 
 */
// 首页主链路使用的枚举和轻量展示模型。
import 'package:flutter/material.dart';

/// App 首页的顶层流程阶段。
enum AppFlowStage { onboarding, paywall, home }

/// 主页底部 Tab 类型。
enum HomeTab { video, create, image }

/// 创作页当前的内容模式。
enum CreationMode { image, video }

/// 创作页顶部轮播卡片的数据模型。
class CreationCardData {
  const CreationCardData({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.secondary,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Color secondary;
  final String badge;
}

/// AI 视频快捷功能入口的数据模型。
class VideoQuickActionData {
  const VideoQuickActionData({required this.label, required this.assetPath});

  final String label;
  final String assetPath;
}

/// 创作页用户角标的数据模型。
class UserBadgeData {
  const UserBadgeData({required this.label, required this.count});

  final String label;
  final String count;
}
