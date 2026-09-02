/*
 * @Author: duncy
 * @Date: 2025-06-04 09:23:28
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-14 15:44:21
 * @FilePath: /novel_oversea/lib/core/ui/dialog/by_dialog_util.dart
 * @Description: 
 */

import 'package:flutter/material.dart';

import 'common_dialog.dart';

/// 用于控制全局警告框弹出
class ByDialogUtil {
  /// 弹出返回确认警告框
  /// [context] 当前上下文
  /// [contents] 警告框的内容
  /// [title] 警告框标题
  /// [confirmBtnTitle] 确认按钮文本
  /// [confirmCallback] 确认按钮回调
  /// [cancelBtnTitle] 取消按钮文本
  /// [cancelCallback] 取消按钮回调
  static Future<bool?> showPopScopeDialog({
    required BuildContext context,
    String? contents,
    String? title,
    String? confirmBtnTitle,
    Function? confirmCallback,
    String? cancelBtnTitle,
    Function? cancelCallback,
    bool? reverse,
    bool? isDanger,
    bool? confirmToBack = false, ///确认之后再返回
  }) {
    return showGeneralDialog<bool>(
      context: context,
      pageBuilder: (context, animation, ctx) {
        return CommonDialog(
          contents: contents ?? 'Network error, need retry, \nGenerate failed would not consume credits',
          title: title,
          confirmBtnTitle: confirmBtnTitle ?? 'Confirm',
          confirmCallback: confirmCallback,
          cancelBtnTitle: cancelBtnTitle,
          cancelCallback: cancelCallback,
          maxLine: 10,
          reverse: reverse ?? true,
          isDanger: isDanger ?? false,
          confirmToBack: confirmToBack ?? false,
        );
      },
      // 自定义过渡动画（核心）
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 缩放动画（从0.8到1.0）
        final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut, // 缓出曲线，更自然
          ),
        );
        // 淡入动画（从0.0到1.0）
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
        );
        // 组合缩放和淡入动画
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child, // child即pageBuilder返回的对话框内容
          ),
        );
      },
    );
  }
}