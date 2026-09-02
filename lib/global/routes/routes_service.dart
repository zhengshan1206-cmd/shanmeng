import 'dart:async';
import 'package:get/get.dart';
import '../../core/network/apis.dart';
import '../../core/network/http_utils.dart';
import '../launch/controller/launch_controller.dart';

class PageRouteService {
  static const String _eventName = 'page_view';

  // 重试次数
  static const int _maxRetryCount = 2;

  // 重试延迟（毫秒）
  static const int _retryDelayMs = 1000;

  // Provider 页面标识映射
  //   /tool_finish_page - 工具完成页面
  // /novel_detail_page - 小说详情页面
  // /novel_brief_page - 小说灵感页面
  // /novel_chapter_detail_page - 小说章节详情页面
  // /novel_outline_detail_page - 小说大纲详情页面
  static final Map<String, String> _providerPageIdentifiers = {
    // 工具完成页面
    'ToolFinishPage': '/tool_finish_page',
    'NameFinishPage': '/name_finish_page',

    // 小说相关页面
    'NovelDetailPage': '/novel_detail_page',
    'NovelBriefPage': '/novel_brief_page',
    'NovelOutlineDetailPage': '/novel_outline_detail_page',
    'NovelChapterDetailPage': '/novel_chapter_detail_page',

    // 其他 Provider 页面
    'OutlineDetailProvider': '/outline_detail_page',
    'ChapterDetailProvider': '/chapter_detail_page',
    'BriefDetailProvider': '/brief_detail_page',

    // 添加更多可能的 Provider 页面
    'NovelDetailProvider': '/novel_detail_page',
    'NovelBriefProvider': '/novel_brief_page',
    'NovelOutlineProvider': '/novel_outline_detail_page',
    'NovelChapterProvider': '/novel_chapter_detail_page',
  };

  // 当前活跃的 Provider 页面标识
  static String? _currentProviderPageId;

  /// 设置当前 Provider 页面标识
  /// [pageId] 页面标识
  static void setCurrentProviderPageId(String pageId) {
    _currentProviderPageId = pageId;
    print('设置 Provider 页面标识: $pageId');
  }

  /// 获取当前 Provider 页面标识
  static String? getCurrentProviderPageId() {
    return _currentProviderPageId;
  }

  /// 清除当前 Provider 页面标识
  static void clearCurrentProviderPageId() {
    _currentProviderPageId = null;
    print('清除 Provider 页面标识');
  }

  /// 根据页面类名获取固定标识
  /// [className] 页面类名
  static String? getProviderPageIdentifier(String className) {
    return _providerPageIdentifiers[className];
  }

  /// 判断是否为 Provider 页面
  /// [className] 页面类名
  static bool isProviderPage(String className) {
    return _providerPageIdentifiers.containsKey(className);
  }

  /// 上报页面访问数据
  /// [duration] 页面停留时长（秒）
  /// [pagePath] 当前页面路由
  /// [prePagePath] 上一个页面路由
  static void reportPageView({
    required double duration,
    required String pagePath,
    required String prePagePath,
  }) {
    final launchInfo = Get.find<LaunchController>().launchInfo;
    final landingPage = launchInfo?.config?.landingPage;
    final Map<String, dynamic> params = {
      'event': _eventName,
      'duration': duration,
      'page_path': prePagePath == '/pay_center_page'
          ? landingPage
          : prePagePath,
      'pre_page_path': pagePath == '/pay_center_page' ? landingPage : pagePath,
    };

    // 使用重试机制上报数据
    _reportWithRetry(params, 0, 'Getx');
  }

  /// 上报 Provider 页面访问数据
  static void reportProviderPageView({
    required double duration,
    required String pagePath,
    required String prePagePath,
  }) {
    final launchInfo = Get.find<LaunchController>().launchInfo;
    final landingPage = launchInfo?.config?.landingPage;
    final Map<String, dynamic> params = {
      'event': _eventName,
      'duration': duration,
      'page_path': prePagePath == '/pay_center_page'
          ? landingPage
          : prePagePath,
      'pre_page_path': pagePath == '/pay_center_page' ? landingPage : pagePath,
    };
    _reportWithRetry(params, 0, 'Provider');
  }

  /// 带重试机制的上报方法
  /// [params] 上报参数
  /// [retryCount] 当前重试次数
  static void _reportWithRetry(
    Map<String, dynamic> params,
    int retryCount,
    String type,
  ) {
    HttpUtils.post(
      APIs.eventReport,
      params,
      showMsgWhenFailed: false,
      success: (data) {
        print('页面路由上报成功:-$type- $params');
      },
      fail: (code, msg) {
        print('页面路由上报失败: $msg, 重试次数: $retryCount');

        // 如果重试次数未达到最大值，则重试
        if (retryCount < _maxRetryCount) {
          Timer(Duration(milliseconds: _retryDelayMs * (retryCount + 1)), () {
            _reportWithRetry(params, retryCount + 1, type);
          });
        } else {
          print('页面路由上报最终失败，已达到最大重试次数: $params');
          // 这里可以添加本地缓存逻辑，将失败的数据保存到本地
          _cacheFailedReport(params);
        }
      },
    );
  }

  /// 缓存失败的上报数据
  /// [params] 上报参数
  static void _cacheFailedReport(Map<String, dynamic> params) {
    // TODO: 实现本地缓存逻辑
    // 可以将失败的数据保存到本地存储，在网络恢复后重新上报
    print('缓存失败的上报数据: $params');
  }

  /// 判断是否为正常页面（排除弹窗类页面）
  /// [routeName] 路由名称
  static bool isNormalPage(String? routeName) {
    if (routeName == null || routeName.isEmpty) {
      return false;
    }

    // 排除弹窗类页面
    final List<String> dialogRoutes = [
      '/dialog',
      '/popup',
      '/modal',
      '/alert',
      '/toast',
      '/loading',
    ];

    // 检查是否包含弹窗相关关键词
    for (String dialogRoute in dialogRoutes) {
      if (routeName.toLowerCase().contains(dialogRoute)) {
        return false;
      }
    }

    // 排除一些特殊的系统页面
    final List<String> systemRoutes = [
      // '/launch',
      // '/launch_fail',
    ];

    if (systemRoutes.contains(routeName)) {
      return false;
    }

    return true;
  }

  /// 判断是否为弹窗页面
  /// [routeName] 路由名称
  static bool isDialogPage(String? routeName) {
    if (routeName == null || routeName.isEmpty) {
      return false;
    }

    // 弹窗类页面关键词
    final List<String> dialogKeywords = [
      'dialog',
      'popup',
      'modal',
      'alert',
      'toast',
      'loading',
      'sheet',
      'bottom_sheet',
      'overlay',
      'snackbar',
      'bottomsheet',
      'cupertino',
      'material',
      'showdialog',
      'showmodal',
      'showbottom',
      'showoverlay',
    ];

    // 检查是否包含弹窗相关关键词
    for (String keyword in dialogKeywords) {
      if (routeName.toLowerCase().contains(keyword)) {
        return true;
      }
    }

    // 特定的弹窗路由
    final List<String> dialogRoutes = [
      '/dialog',
      '/popup',
      '/modal',
      '/alert',
      '/toast',
      '/loading',
      '/sheet',
      '/bottom_sheet',
      '/overlay',
      '/snackbar',
      '/bottomsheet',
    ];

    if (dialogRoutes.contains(routeName)) {
      return true;
    }

    return false;
  }

  /// 判断是否为临时页面（弹窗、覆盖层等）
  /// [routeName] 路由名称
  static bool isTemporaryPage(String? routeName) {
    return isDialogPage(routeName);
  }

  /// 判断是否为主页面路由
  /// [routeName] 路由名称
  static bool isMainPageRoute(String? routeName) {
    if (routeName == null) return false;

    final List<String> mainPageRoutes = [
      '/main',
      '/home',
      '/square',
      '/profile',
    ];

    return mainPageRoutes.contains(routeName);
  }

  /// 判断是否为main路由（需要特殊处理）
  /// [routeName] 路由名称
  static bool isMainRoute(String? routeName) {
    return routeName == '/main';
  }

  /// 获取实际的主页面路由（将/main转换为具体的子页面）
  /// [routeName] 路由名称
  /// [currentMainIndex] 当前主页面索引
  static String getActualMainPageRoute(
    String? routeName, [
    int? currentMainIndex,
  ]) {
    if (routeName == '/main') {
      // 根据当前主页面索引返回具体路由
      switch (currentMainIndex ?? 0) {
        case 0:
          return '/home';
        case 1:
          return '/square';
        case 2:
          return '/profile';
        default:
          return '/home';
      }
    }
    return routeName ?? '';
  }

  /// 获取主页面路由的显示名称
  /// [routeName] 路由名称
  static String getMainPageDisplayName(String? routeName) {
    if (routeName == null) return '';

    switch (routeName) {
      case '/home':
        return '首页';
      case '/square':
        return '广场';
      case '/profile':
        return '我的';
      case '/main':
        return '主页';
      default:
        return routeName;
    }
  }

  /// 获取页面停留时长的可读格式
  static String getDurationText(int duration) {
    return '$duration秒';
  }

  /// 获取页面停留时长（秒，保留两位小数）
  /// [duration] 停留时长（秒）
  static double getDurationInSeconds(double duration) {
    return double.parse(duration.toStringAsFixed(2));
  }
}
