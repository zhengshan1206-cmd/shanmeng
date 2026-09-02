import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../network/apis.dart';
import '../network/http_utils.dart';
import '../ui/dialog/toast.dart';
import '../ui/view/byhy_base_web_view.dart';

/// description:  路由跳转工具类（原生封装）

class ByNavRouterUtils {
  static void fadeIn(BuildContext context, Widget scene, {String? name}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        settings: name != null ? RouteSettings(name: name) : null,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = 0.8;
          var end = 1.0;
          var curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return FadeTransition(opacity: animation.drive(tween), child: child);
        },
      ),
    );
  }

  /// 跳转
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致滑动返回卡顿和点击失效的问题
  /// 使用 PageRouteBuilder 自定义淡入淡出动画，不缩放，像旧版本一样自然
  static Future push(BuildContext context, Widget scene, {String? name}) {
    FocusScope.of(context).requestFocus(FocusNode());

    // 如果没有传递 name，尝试从 GetX 获取当前路由作为备用
    String? routeName = name;
    if (routeName == null || routeName.isEmpty) {
      try {
        final getXRoute = Get.currentRoute;
        if (getXRoute.isNotEmpty && getXRoute != '/') {
          routeName = getXRoute;
        }
      } catch (e) {
        // GetX 未初始化或获取失败，忽略
      }
    }

    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        settings: routeName != null ? RouteSettings(name: routeName) : null,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放，修复 Flutter 新版本的缩放问题
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// 跳转Name
  static dynamic pushNamed(
    BuildContext context,
    String name, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(context, name, arguments: arguments);
  }

  /// 跳转Name
  static dynamic pushReplacementNamed(
    BuildContext context,
    String name, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(context, name, arguments: arguments);
  }

  /// 替换页面 当新的页面进入后，之前的页面将执行dispose方法
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static dynamic pushReplacement(
    BuildContext context,
    Widget scene, {
    String? name,
  }) {
    return Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        settings: name != null ? RouteSettings(name: name) : null,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// 指定页面加入到路由中，然后将其他所有的页面全部pop
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static dynamic pushAndRemoveUntil(BuildContext context, Widget scene) {
    return Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  ///  跳转 - 带回调参数
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static void pushNamedResult(
    BuildContext context,
    Widget scene,
    Function(dynamic) function,
  ) {
    Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => scene,
            transitionDuration: const Duration(milliseconds: 200),
            reverseTransitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // 使用淡入淡出动画，不缩放
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        )
        .then((result) {
          // 页面返回result为null
          if (result == null) {
            return;
          }
          function(result);
        })
        .catchError((error) {});
  }

  /// 返回
  static void goBack(BuildContext context) {
    unFocus();
    Navigator.pop(context);
  }

  /// 返回
  static void goBackUntilName(BuildContext context, String name) {
    unFocus();
    Navigator.popUntil(context, (route) {
      return route.settings.name == name;
    });
  }

  /// 带参数返回
  static void goBackWithParams(BuildContext context, result) {
    unFocus();
    Navigator.pop(context, result);
  }

  /// 跳到WebView页
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static void jumpWebViewPage(
    BuildContext context,
    String title,
    String url, {
    bool isRisk = true,
    String? closeOnAppLinkPrefix,
  }) {
    if (url.isEmpty) return;

    // 创建自定义路由，使用淡入淡出动画
    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ByHyBaseWebView(
        title: title,
        url: url,
        closeOnAppLinkPrefix: closeOnAppLinkPrefix,
      ),
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用淡入淡出动画，不缩放
        return FadeTransition(opacity: animation, child: child);
      },
    );

    if (isRisk) {
      HttpUtils.post(
        APIs.dnsCheck,
        {"url": url},
        success: (json) {
          Navigator.push(context, route);
        },
        fail: (code, msg) {
          Toast.showText(text: msg);
        },
      );
    } else {
      Navigator.push(context, route);
    }
  }

  /// 跳到WebView页 - 带返回值
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static dynamic jumpWebViewPageResult(
    BuildContext context,
    String title,
    String url, {
    String? closeOnAppLinkPrefix,
  }) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ByHyBaseWebView(
              title: title,
              url: url,
              closeOnAppLinkPrefix: closeOnAppLinkPrefix,
            ),
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
  //    Navigator.of(context)
  //        .push(new MaterialPageRoute(builder: (_) {
  //      return WebViewPage(title:'作者博客', url: 'https://blog.csdn.net/iotjin');
  //
  //    }));

  static void unFocus() {
    /// 使用下面的方式，会触发不必要的build。
    /// FocusScope.of(context).unFocus();
    /// https://blog.csdn.net/iotjin
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
