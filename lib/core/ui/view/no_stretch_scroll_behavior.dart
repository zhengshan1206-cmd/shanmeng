import 'package:flutter/material.dart';

/// 关闭 Flutter 默认的 overscroll 拉伸效果，
/// 保留原有滚动与回弹行为，避免 BackdropFilter 在拉伸时采样错位。
class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
