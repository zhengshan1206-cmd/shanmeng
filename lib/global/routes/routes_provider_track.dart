/*
 * @Author: duncy
 * @Date: 2025-12-04 11:20:33
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-12-04 11:33:34
 * @FilePath: /novel_oversea/lib/global/routes/routes_provider_track.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/util/by_nav_router_utils.dart';
import 'routes_service.dart';

/// Provider 页面跟踪器
/// 用于包装 Provider 页面，自动处理埋点
class ProviderPageTracker extends StatefulWidget {
  final String pageId;
  final Widget child;

  const ProviderPageTracker({
    super.key,
    required this.pageId,
    required this.child,
  });

  @override
  State<ProviderPageTracker> createState() => _ProviderPageTrackerState();
}

class _ProviderPageTrackerState extends State<ProviderPageTracker> {
  @override
  void initState() {
    super.initState();
    PageRouteService.setCurrentProviderPageId(widget.pageId);
    print('Provider 页面跟踪器初始化: ${widget.pageId}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PageRouteService.getCurrentProviderPageId() != widget.pageId) {
      PageRouteService.setCurrentProviderPageId(widget.pageId);
    }
  }

  @override
  void dispose() {
    // 清除当前 Provider 页面标识
    PageRouteService.clearCurrentProviderPageId();
    print('Provider 页面跟踪器销毁: ${widget.pageId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ProviderPageTrackerManager {
  /// 便捷方法：为 Provider 页面添加埋点支持
  /// [pageId] 页面标识
  /// [widget] 页面 Widget
  static void trackProviderPage({required String pageId, required Widget widget, int pushType = 0, Function()? after}) {
    ///pushReplacement
    final Widget child = ProviderPageTracker(
              pageId: pageId,
              child: widget,
            );
    if(pushType == 1) {
      ByNavRouterUtils.pushReplacement(Get.context!, child).then((_){
        after?.call();
      });
      return;
    }
    ByNavRouterUtils.push(Get.context!, child,).then((_){
        after?.call();
      });
  }
}


