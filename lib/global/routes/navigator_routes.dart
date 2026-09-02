import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/global/routes/routes_service.dart';
import '../main/main_controller.dart';

class MyRouteObserver extends GetObserver with WidgetsBindingObserver {
  // 存储页面进入时间
  final Map<String, DateTime> _pageEnterTimes = {};

  // 当前活跃页面
  String? _currentActivePage;

  // 应用进入后台的时间
  DateTime? _appPausedTime;

  // 主页面控制器引用
  MainController? _mainController;

  // 存储弹窗覆盖状态
  final Map<String, bool> _pageDialogOverlayStatus = {};

  // Provider 页面进入时间记录
  final Map<String, DateTime> _providerPageEnterTimes = {};

  // 当前活跃的 Provider 页面标识
  String? _currentProviderPageId;

  MyRouteObserver() {
    // 监听应用生命周期
    WidgetsBinding.instance.addObserver(this);
  }

  /// 清理资源
  void dispose() {
    // 移除应用生命周期监听
    WidgetsBinding.instance.removeObserver(this);

    // 上报当前活跃页面的停留时长
    if (_currentActivePage != null &&
        _pageEnterTimes.containsKey(_currentActivePage)) {
      _reportPageDuration(_currentActivePage!, null);
    }

    // 上报当前活跃的 Provider 页面停留时长
    if (_currentProviderPageId != null &&
        _providerPageEnterTimes.containsKey(_currentProviderPageId)) {
      _reportProviderPageDuration(_currentProviderPageId!, null);
    }

    // 清空数据
    _pageEnterTimes.clear();
    _currentActivePage = null;
    _appPausedTime = null;
    _mainController = null;
    _pageDialogOverlayStatus.clear();
    _providerPageEnterTimes.clear();
    _currentProviderPageId = null;
  }

  // 应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // 应用进入后台
        _appPausedTime = DateTime.now();
        if (_currentActivePage != null) {
          // 应用进入后台时，下一个页面路径应该是当前页面本身（表示用户还在当前页面）
          _reportPageDuration(_currentActivePage!, _currentActivePage!);
        }
        if (_currentProviderPageId != null) {
          // Provider页面同样处理
          _reportProviderPageDuration(
            _currentProviderPageId!,
            _currentProviderPageId!,
          );
        }
        break;
      case AppLifecycleState.resumed:
        // 应用恢复前台
        if (_currentActivePage != null && _appPausedTime != null) {
          // 重新记录页面进入时间
          _pageEnterTimes[_currentActivePage!] = DateTime.now();
        }
        if (_currentProviderPageId != null && _appPausedTime != null) {
          // 重新记录 Provider 页面进入时间
          _providerPageEnterTimes[_currentProviderPageId!] = DateTime.now();
        }
        _appPausedTime = null;
        break;
      default:
        break;
    }
  }

  // 页面即将显示
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    final String? currentRouteName = route.settings.name;
    final String? previousRouteName = previousRoute?.settings.name;

    // print("______页面即将显示：$currentRouteName,上一个页面：$previousRouteName");

    // 检查是否为 Provider 页面
    final String? providerPageId = _detectProviderPage(route);
    if (providerPageId != null) {
      _handleProviderPagePush(providerPageId, previousRouteName);
      return;
    }

    // 如果检测失败，但路由包含 ProviderPageTracker，延迟处理
    if (route is MaterialPageRoute) {
      try {
        final Widget widget = route.builder(Get.context!);
        if (widget.runtimeType.toString().contains('ProviderPageTracker')) {
          print("检测到路由包含 ProviderPageTracker，等待全局标识设置");
          Future.delayed(Duration(milliseconds: 100), () {
            final String? delayedProviderId =
                PageRouteService.getCurrentProviderPageId();
            if (delayedProviderId != null) {
              print("延迟检测到 Provider 页面: $delayedProviderId");
              _handleProviderPagePush(delayedProviderId, previousRouteName);
            }
          });
          return;
        }
      } catch (e) {
        print('检查路由 Widget 失败: $e');
      }
    }

    // 处理从Provider页面跳转到普通页面的情况
    if (_currentProviderPageId != null) {
      print('从Provider页面跳转到普通页面，先清除Provider页面状态');
      // 上报当前Provider页面的停留时长
      _reportProviderPageDuration(_currentProviderPageId!, currentRouteName);
      // 清除Provider页面状态
      _currentProviderPageId = null;
      PageRouteService.clearCurrentProviderPageId();
    }

    // 处理/main路由，转换为实际的主页面路由
    final String? actualCurrentRoute = _getActualMainPageRoute(
      currentRouteName,
    );
    final String? actualPreviousRoute = _getActualMainPageRoute(
      previousRouteName,
    );

    // 判断当前页面是否为弹窗（包括null路由）
    final bool isCurrentDialog = _isDialogRoute(currentRouteName, route);

    // 如果当前页面是弹窗，标记当前活跃页面被弹窗覆盖
    if (isCurrentDialog && _currentActivePage != null) {
      _pageDialogOverlayStatus[_currentActivePage!] = true;
      // print('页面被弹窗覆盖: $_currentActivePage');
      return; // 弹窗不改变活跃页面，继续使用原来的页面进行时间统计
    }

    // 如果上一个页面是主页面，先上报主页面的埋点
    if (actualPreviousRoute != null && _isMainPageRoute(actualPreviousRoute)) {
      _reportMainPageDuration(actualPreviousRoute, actualCurrentRoute);
    }

    // 处理主页面路由变化（但不阻止普通页面埋点）
    if (_isMainPageRoute(actualCurrentRoute)) {
      _handleMainPageRouteChange(actualCurrentRoute, actualPreviousRoute);
    }

    // 记录当前页面进入时间（使用实际路由名称）
    if (actualCurrentRoute != null) {
      _pageEnterTimes[actualCurrentRoute] = DateTime.now();
      _currentActivePage = actualCurrentRoute;
      // 清除弹窗覆盖状态
      _pageDialogOverlayStatus[actualCurrentRoute] = false;
    }

    // 如果上一个页面存在且不是主页面，计算并上报上一个页面的停留时长
    if (actualPreviousRoute != null &&
        _pageEnterTimes.containsKey(actualPreviousRoute) &&
        !_isMainPageRoute(actualPreviousRoute)) {
      _reportPageDuration(actualPreviousRoute, actualCurrentRoute);
    }
  }

  // 页面即将消失（被新页面覆盖）
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    final String? newRouteName = newRoute?.settings.name;
    final String? oldRouteName = oldRoute?.settings.name;

    // print("_____页面即将消失：$oldRouteName, 替换为：$newRouteName");

    // 检查新页面是否为 Provider 页面
    final String? newProviderPageId = _detectProviderPage(newRoute);
    if (newProviderPageId != null) {
      _handleProviderPageReplace(newProviderPageId, oldRouteName);
      return;
    }

    // 处理从Provider页面跳转到普通页面的情况
    if (_currentProviderPageId != null) {
      // print('从Provider页面跳转到普通页面（Replace），先清除Provider页面状态');
      // 上报当前Provider页面的停留时长
      _reportProviderPageDuration(_currentProviderPageId!, newRouteName);
      // 清除Provider页面状态
      _currentProviderPageId = null;
      PageRouteService.clearCurrentProviderPageId();
    }

    // 处理/main路由，转换为实际的主页面路由
    final String? actualNewRoute = _getActualMainPageRoute(newRouteName);
    final String? actualOldRoute = _getActualMainPageRoute(oldRouteName);

    // 判断新页面是否为弹窗
    final bool isNewDialog = _isDialogRoute(newRouteName, newRoute);

    // 如果新页面是弹窗，标记当前活跃页面被弹窗覆盖
    if (isNewDialog && _currentActivePage != null) {
      _pageDialogOverlayStatus[_currentActivePage!] = true;
      // print('页面被弹窗覆盖: $_currentActivePage');
      return; // 弹窗不改变活跃页面，继续使用原来的页面进行时间统计
    }

    // 如果被替换的页面是主页面，先上报主页面的埋点
    if (actualOldRoute != null && _isMainPageRoute(actualOldRoute)) {
      _reportMainPageDuration(actualOldRoute, actualNewRoute);
    }

    // 处理主页面路由变化（但不阻止普通页面埋点）
    if (_isMainPageRoute(actualNewRoute) || _isMainPageRoute(actualOldRoute)) {
      _handleMainPageRouteChange(actualNewRoute, actualOldRoute);
    }

    // 记录新页面进入时间（使用实际路由名称）
    if (actualNewRoute != null) {
      _pageEnterTimes[actualNewRoute] = DateTime.now();
      _currentActivePage = actualNewRoute;
      // 清除弹窗覆盖状态
      _pageDialogOverlayStatus[actualNewRoute] = false;
    }

    // 计算并上报被替换页面的停留时长（如果不是主页面）
    if (actualOldRoute != null &&
        _pageEnterTimes.containsKey(actualOldRoute) &&
        !_isMainPageRoute(actualOldRoute)) {
      _reportPageDuration(actualOldRoute, actualNewRoute);
    }
  }

  // 页面即将显示（从后台返回）
  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);

    final String? currentRouteName = route.settings.name;
    final String? previousRouteName = previousRoute?.settings.name;

    // print("_____页面即将显示（返回）：$previousRouteName, 当前页面：$currentRouteName");

    // 检查是否为 Provider 页面
    final String? providerPageId = _detectProviderPage(route);
    if (providerPageId != null) {
      _handleProviderPageRemove(providerPageId, previousRouteName);
      return;
    }

    // 处理从Provider页面跳转到普通页面的情况
    if (_currentProviderPageId != null) {
      // print('从Provider页面跳转到普通页面（Remove），先清除Provider页面状态');
      // 上报当前Provider页面的停留时长
      _reportProviderPageDuration(_currentProviderPageId!, currentRouteName);
      // 清除Provider页面状态
      _currentProviderPageId = null;
      PageRouteService.clearCurrentProviderPageId();
    }

    // 处理/main路由，转换为实际的主页面路由
    final String? actualCurrentRoute = _getActualMainPageRoute(
      currentRouteName,
    );
    final String? actualPreviousRoute = _getActualMainPageRoute(
      previousRouteName,
    );

    // 判断当前页面是否为弹窗
    final bool isCurrentDialog = _isDialogRoute(currentRouteName, route);

    // 如果当前页面是弹窗，标记当前活跃页面被弹窗覆盖
    if (isCurrentDialog && _currentActivePage != null) {
      _pageDialogOverlayStatus[_currentActivePage!] = true;
      // print('页面被弹窗覆盖: $_currentActivePage');
      return; // 弹窗不改变活跃页面，继续使用原来的页面进行时间统计
    }

    // 处理主页面路由变化（但不阻止普通页面埋点）
    if (_isMainPageRoute(actualCurrentRoute)) {
      _handleMainPageRouteChange(actualCurrentRoute, actualPreviousRoute);
    }

    // 记录当前页面进入时间（使用实际路由名称）
    if (actualCurrentRoute != null) {
      _pageEnterTimes[actualCurrentRoute] = DateTime.now();
      _currentActivePage = actualCurrentRoute;
      // 清除弹窗覆盖状态
      _pageDialogOverlayStatus[actualCurrentRoute] = false;
    }
  }

  // 页面即将销毁
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    final String? currentRouteName = route.settings.name;
    final String? previousRouteName = previousRoute?.settings.name;

    // print("_____页面即将销毁：$currentRouteName, 上一个页面：$previousRouteName");

    // 检查当前页面是否为 Provider 页面
    final String? currentProviderPageId = _detectProviderPage(route);
    if (currentProviderPageId != null) {
      _handleProviderPagePop(currentProviderPageId, previousRouteName);
      return;
    }

    // 处理/main路由，转换为实际的主页面路由
    final String? actualCurrentRoute = _getActualMainPageRoute(
      currentRouteName,
    );
    final String? actualPreviousRoute = _getActualMainPageRoute(
      previousRouteName,
    );

    // 判断当前页面是否为弹窗
    final bool isCurrentDialog = _isDialogRoute(currentRouteName, route);

    // 如果当前页面是弹窗，清除弹窗覆盖状态
    if (isCurrentDialog && _currentActivePage != null) {
      _pageDialogOverlayStatus[_currentActivePage!] = false;
      // print('弹窗关闭，页面恢复: $_currentActivePage');
      return; // 弹窗关闭不影响活跃页面的时间统计
    }

    // 如果当前页面是主页面，先上报主页面的埋点
    if (actualCurrentRoute != null && _isMainPageRoute(actualCurrentRoute)) {
      _reportMainPageDuration(actualCurrentRoute, actualPreviousRoute);
    }

    // 处理主页面路由变化（但不阻止普通页面埋点）
    if (_isMainPageRoute(actualCurrentRoute) ||
        _isMainPageRoute(actualPreviousRoute)) {
      _handleMainPageRouteChange(actualPreviousRoute, actualCurrentRoute);
    }

    // 计算并上报当前页面的停留时长（如果不是主页面）
    if (actualCurrentRoute != null &&
        _pageEnterTimes.containsKey(actualCurrentRoute) &&
        !_isMainPageRoute(actualCurrentRoute)) {
      _reportPageDuration(actualCurrentRoute, actualPreviousRoute);
    }

    // 记录上一个页面的进入时间（如果存在）
    if (actualPreviousRoute != null) {
      _pageEnterTimes[actualPreviousRoute] = DateTime.now();
      _currentActivePage = actualPreviousRoute;
      // 清除弹窗覆盖状态
      _pageDialogOverlayStatus[actualPreviousRoute] = false;
    }
  }

  /// 判断是否为弹窗路由（增强版，包括null路由的检测）
  bool _isDialogRoute(String? routeName, Route? route) {
    // 首先检查路由名称
    if (PageRouteService.isTemporaryPage(routeName)) {
      return true;
    }

    // 如果路由名称为null，通过路由类型判断
    if (routeName == null && route != null) {
      // 检查是否为弹窗类型的路由
      if (route is DialogRoute ||
          route is PopupRoute ||
          route.runtimeType.toString().toLowerCase().contains('dialog') ||
          route.runtimeType.toString().toLowerCase().contains('popup') ||
          route.runtimeType.toString().toLowerCase().contains('modal')) {
        return true;
      }
    }

    return false;
  }

  /// 判断是否为主页面路由
  bool _isMainPageRoute(String? routeName) {
    if (routeName == null) return false;

    return routeName == '/home' ||
        routeName == '/square' ||
        routeName == '/profile';
  }

  /// 获取实际的主页面路由（将/main转换为具体的子页面）
  String? _getActualMainPageRoute(String? routeName) {
    if (routeName == '/main') {
      // 获取当前主页面控制器的活跃页面
      if (_mainController != null) {
        final currentIndex = _mainController!.currentIndex.value;
        return PageRouteService.getActualMainPageRoute(routeName, currentIndex);
      }
      return '/home'; // 默认返回首页
    }
    return routeName;
  }

  /// 处理主页面路由变化
  void _handleMainPageRouteChange(String? newRouteName, String? oldRouteName) {
    // 获取主页面控制器
    if (_mainController == null) {
      try {
        _mainController = Get.find<MainController>();
      } catch (e) {
        print('主页面控制器未找到: $e');
        return;
      }
    }

    // 根据路由名称确定页面索引
    int? newPageIndex = _getPageIndexFromRoute(newRouteName);
    int? oldPageIndex = _getPageIndexFromRoute(oldRouteName);

    if (newPageIndex != null) {
      // 上报上一个页面的停留时长
      if (oldPageIndex != null && oldPageIndex != newPageIndex) {
        _mainController!.reportPageDuration(oldPageIndex, newPageIndex);
      }

      // 记录新页面进入时间（使用路由专用方法）
      _mainController!.recordPageEnterFromRoute(newPageIndex);
    }
  }

  /// 根据路由名称获取页面索引
  int? _getPageIndexFromRoute(String? routeName) {
    if (routeName == null) return null;

    switch (routeName) {
      case '/home':
        return 0;
      case '/square':
        return 1;
      case '/profile':
        return 2;
      default:
        return null;
    }
  }

  /// 计算并上报页面停留时长
  /// [pagePath] 页面路由
  /// [nextPagePath] 下一个页面路由
  void _reportPageDuration(String pagePath, String? nextPagePath) {
    // 跳过主页面路由的上报，因为主页面有自己的埋点逻辑
    if (PageRouteService.isMainPageRoute(pagePath)) {
      print('跳过主页面路由上报（使用主页面埋点）: $pagePath');
      return;
    }

    // // 防止重复上报
    // final String reportKey = '$pagePath->$nextPagePath';
    // if (_reportedPages.contains(reportKey)) {
    //   print('页面已上报，跳过重复上报: $reportKey');
    //   return;
    // }

    final DateTime? enterTime = _pageEnterTimes[pagePath];
    if (enterTime == null) {
      print('页面进入时间未找到: $pagePath');
      return;
    }

    // 计算停留时长（秒，保留两位小数）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 移除已上报的页面时间记录
    _pageEnterTimes.remove(pagePath);

    // // 标记已上报
    // _reportedPages.add(reportKey);

    // 上报页面访问数据（修正参数顺序）
    PageRouteService.reportPageView(
      duration: duration,
      pagePath: pagePath,
      prePagePath: nextPagePath ?? '',
    );

    // final String durationText =
    //     PageRouteService.getDurationText(duration.round());
    // print('页面路由上报: 页面=$pagePath, 时长=$durationText, 下一页=$nextPagePath');
  }

  /// 计算并上报主页面停留时长
  /// [pagePath] 页面路由
  /// [nextPagePath] 下一个页面路由
  void _reportMainPageDuration(String pagePath, String? nextPagePath) {
    // 获取主页面控制器
    if (_mainController == null) {
      try {
        _mainController = Get.find<MainController>();
      } catch (e) {
        print('主页面控制器未找到: $e');
        return;
      }
    }

    // 使用主页面控制器的埋点逻辑
    _mainController!.reportMainPageLeave(nextPagePath ?? '');
  }

  /// 检测 Provider 页面
  /// [route] 路由对象
  /// 返回 Provider 页面标识，如果不是 Provider 页面则返回 null
  String? _detectProviderPage(Route? route) {
    if (route == null) return null;

    // 首先检查是否有全局 Provider 页面标识（最可靠的方法）
    final String? currentProviderId =
        PageRouteService.getCurrentProviderPageId();
    if (currentProviderId != null) {
      print('检测到全局 Provider 页面标识: $currentProviderId');
      return currentProviderId;
    }

    // 检查路由是否包含 ProviderPageTracker
    if (route is MaterialPageRoute) {
      try {
        final Widget widget = route.builder(Get.context!);
        if (widget.runtimeType.toString().contains('ProviderPageTracker')) {
          print('检测到路由包含 ProviderPageTracker');
          return _extractPageIdFromProviderPageTracker(widget);
        }
      } catch (e) {
        print('从路由提取 Widget 失败: $e');
      }
    }

    // 检查路由名称是否匹配已知的 Provider 页面
    if (route.settings.name != null) {
      final List<String> knownProviderRoutes = [
        '/tool_finish_page',
        '/novel_detail_page',
        '/novel_brief_page',
        '/novel_chapter_detail_page',
        '/novel_outline_detail_page',
      ];

      if (knownProviderRoutes.contains(route.settings.name!)) {
        print('通过路由名称检测到 Provider 页面: ${route.settings.name}');
        return route.settings.name;
      }
    }

    print('未检测到 Provider 页面 ${route.settings.name}');
    return null;
  }

  /// 从 ProviderPageTracker 中提取页面ID
  /// [widget] ProviderPageTracker Widget
  /// 返回页面ID，如果无法提取则返回 null
  String? _extractPageIdFromProviderPageTracker(Widget widget) {
    try {
      // 使用反射获取 pageId
      final dynamic tracker = widget;
      final dynamic pageId = tracker.pageId;
      if (pageId != null && pageId is String) {
        print('从 ProviderPageTracker 提取到页面ID: $pageId');
        return pageId;
      }
    } catch (e) {
      print('从 ProviderPageTracker 提取页面ID 失败: $e');
    }
    return null;
  }

  /// 处理 Provider 页面 Push 事件
  void _handleProviderPagePush(
    String providerPageId,
    String? previousRouteName,
  ) {
    // 上报上一个页面的停留时长
    if (_currentActivePage != null) {
      _reportPageDuration(_currentActivePage!, providerPageId);
    }
    if (_currentProviderPageId != null) {
      _reportProviderPageDuration(_currentProviderPageId!, providerPageId);
    }

    // 记录 Provider 页面进入时间
    _providerPageEnterTimes[providerPageId] = DateTime.now();
    _currentProviderPageId = providerPageId;
    PageRouteService.setCurrentProviderPageId(providerPageId);
    print('Provider页面状态已设置: $_currentProviderPageId');
  }

  /// 处理 Provider 页面 Replace 事件
  void _handleProviderPageReplace(
    String newProviderPageId,
    String? oldRouteName,
  ) {
    print('Provider页面Replace: $newProviderPageId, 旧页面: $oldRouteName');

    // 上报上一个页面的停留时长
    if (_currentActivePage != null) {
      _reportPageDuration(_currentActivePage!, newProviderPageId);
    }
    if (_currentProviderPageId != null) {
      _reportProviderPageDuration(_currentProviderPageId!, newProviderPageId);
    }

    // 记录新 Provider 页面进入时间
    _providerPageEnterTimes[newProviderPageId] = DateTime.now();
    _currentProviderPageId = newProviderPageId;
    PageRouteService.setCurrentProviderPageId(newProviderPageId);
  }

  /// 处理 Provider 页面 Remove 事件
  void _handleProviderPageRemove(
    String providerPageId,
    String? previousRouteName,
  ) {
    // 记录 Provider 页面进入时间
    _providerPageEnterTimes[providerPageId] = DateTime.now();
    _currentProviderPageId = providerPageId;
    PageRouteService.setCurrentProviderPageId(providerPageId);
  }

  /// 处理 Provider 页面 Pop 事件
  void _handleProviderPagePop(
    String currentProviderPageId,
    String? previousRouteName,
  ) {
    // 上报当前 Provider 页面的停留时长
    _reportProviderPageDuration(currentProviderPageId, previousRouteName);

    // 清除当前 Provider 页面标识
    _currentProviderPageId = null;
    PageRouteService.clearCurrentProviderPageId();

    // 如果上一个页面存在，记录其进入时间
    if (previousRouteName != null) {
      _pageEnterTimes[previousRouteName] = DateTime.now();
      _currentActivePage = previousRouteName;
    }
  }

  /// 计算并上报 Provider 页面停留时长
  void _reportProviderPageDuration(String pageId, String? nextPagePath) {
    final DateTime? enterTime = _providerPageEnterTimes[pageId];
    if (enterTime == null) {
      print('Provider 页面进入时间未找到: $pageId');
      return;
    }

    // 计算停留时长（秒）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 移除已上报的页面时间记录
    _providerPageEnterTimes.remove(pageId);

    // 上报 Provider 页面访问数据
    PageRouteService.reportProviderPageView(
      duration: duration,
      pagePath: pageId,
      prePagePath: nextPagePath ?? '',
    );

    final String durationText = PageRouteService.getDurationText(
      duration.round(),
    );
    print('Provider 页面路由上报完成: 页面=$pageId, 时长=$durationText, 下一页=$nextPagePath');
  }
}
