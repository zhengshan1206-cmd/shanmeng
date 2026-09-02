/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:51:03
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-25 10:27:59
 * @FilePath: /ling_bao/lib/global/main/main_controller.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/global/launch/controller/launch_controller.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/user/user.dart';
import 'package:ling_bao/image/home_image_controller.dart';
import 'package:ling_bao/video/main/controller/home_video_controller.dart';
import 'package:ling_bao/profile/main/page/profile_page.dart';
import '../../create/home_create_type_dialog.dart';
import '../login/controller/onekey_manager.dart';
import '../routes/app_pages.dart';
import '../routes/routes_service.dart';

class MainController extends GetxController {
  Rx<int> currentIndex = 0.obs;

  ///启动接口状态
  Rx<MultiStatusType> launchStatus = MultiStatusType.statusLoading.obs;
  LaunchController launchController = Get.find<LaunchController>();

  // 页面进入时间记录
  final Map<int, DateTime> _pageEnterTimes = {};

  // 当前活跃页面索引
  int? _currentActivePageIndex;

  // 是否正在处理路由变化（避免重复上报）
  bool _isHandlingRouteChange = false;

  @override
  void onInit() {
    super.onInit();
    fetchLaunchData();
    _initOnekey();
  }

  /// 初始化一键登录
  void _initOnekey() {
    OneKeyManager.init();
  }

  /// 进入个人中心页
  void openProfile() {
    Get.toNamed(Routes.userProfile);
  }

  /// 进入付费页
  void openPayWall() {
    Get.find<UserController>().jumpToPayPage();
  }

  /// 进入客服中心
  void openSupportl() {
    GlobalController.instance.config.goPrivacyPageWithTitle('在线客服');
  }

  ///加载启动数据
  void fetchLaunchData() {
    ///是否有启动接口
    if (launchController.isLaunched.value) {
      launchStatus.value = MultiStatusType.statusContent;
      loadData();
    } else {
      launchStatus.value = MultiStatusType.statusLoading;
      launchController.appLaunch(
        onSuccess: (p0) {
          launchStatus.value = MultiStatusType.statusContent;
          loadData();
        },
        onFail: () {
          launchStatus.value = MultiStatusType.statusNoNetWork;
        },
      );
    }
  }

  /// 展示底部创作类型抽屉。
  ///
  /// 中间 Tab 不直接切页，而是先让用户选择“图生视频 / AI绘图”等具体能力。
  Future<void> openCreateTypeDialog({GenerateCategory category = .all}) async {
    await showGeneralDialog<void>(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: '创作类型',
      barrierColor: Colors.black.withValues(alpha: 0.93),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CreateTypeDialog(
          category: category,
          onClose: () => Get.back(),
          onSelect: (entry) {
            Get.back();
            openCreateFlow(entry);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// 打开某个具体创作类型页面。
  Future<void> openCreateFlow(CreateTypeEntryData entry) async {
    Get.toNamed(Routes.create, arguments: {'entry': entry});
  }

  ///加载主页以及各个tab页数据
  void loadData() {
    final bool home = Get.isRegistered<HomeVideoController>();
    if (!home) {
      Get.put(HomeVideoController(), permanent: true);
    }
    Get.put(HomeImageController(), permanent: true);
    GlobalController.instance.init();
  }

  void tabChanged(int index) {
    // 如果正在处理路由变化，跳过tab切换的埋点
    if (_isHandlingRouteChange) {
      currentIndex.value = index;
      return;
    }

    if (index == 1) {
      openCreateTypeDialog(category: .all);
      return;
    }

    if (currentIndex.value == index) {
      return;
    }

    currentIndex.value = index;

    if (index == 1) {
    } else if (index == 2) {
    } else if (index == 0) {}
  }

  /// 记录页面进入时间
  void recordPageEnter(int index) {
    _pageEnterTimes[index] = DateTime.now();
    _currentActivePageIndex = index;
  }

  /// 记录页面进入时间（用于路由变化）
  void recordPageEnterFromRoute(int index) {
    _isHandlingRouteChange = true;
    recordPageEnter(index);
    currentIndex.value = index;
    _isHandlingRouteChange = false;
  }

  /// 上报页面停留时长
  void reportPageDuration(int pageIndex, [int? nextPageIndex]) {
    final DateTime? enterTime = _pageEnterTimes[pageIndex];
    if (enterTime == null) return;

    // 计算停留时长（秒，保留两位小数）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 获取页面路由名称
    final String pagePath = _getPagePath(pageIndex);
    final String prePagePath = nextPageIndex != null
        ? _getPagePath(nextPageIndex)
        : '';

    // 上报页面访问数据
    PageRouteService.reportPageView(
      duration: duration,
      pagePath: pagePath,
      prePagePath: prePagePath,
    );

    // 移除已上报的页面时间记录
    _pageEnterTimes.remove(pageIndex);
  }

  /// 上报主页面离开时的埋点（用于路由监听器调用）
  void reportMainPageLeave(String nextPagePath) {
    if (_currentActivePageIndex == null) return;

    final DateTime? enterTime = _pageEnterTimes[_currentActivePageIndex];
    if (enterTime == null) return;

    // 计算停留时长（秒，保留两位小数）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 获取页面路由名称
    final String pagePath = _getPagePath(_currentActivePageIndex!);

    // 上报页面访问数据
    PageRouteService.reportPageView(
      duration: duration,
      pagePath: pagePath,
      prePagePath: nextPagePath,
    );

    // 移除已上报的页面时间记录
    _pageEnterTimes.remove(_currentActivePageIndex);

    // 清空当前活跃页面索引，因为主页面已经离开
    _currentActivePageIndex = null;
  }

  /// 获取页面路由路径
  String _getPagePath(int index) {
    switch (index) {
      case 0:
        return Routes.home;
      case 1:
        return Routes.square;
      case 2:
        return Routes.profile;
      default:
        return Routes.main;
    }
  }
}
