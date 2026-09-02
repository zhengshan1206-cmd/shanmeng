// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ling_bao/core/common/event/common_event.dart';
import 'package:ling_bao/core/ui/view/by_common_utils.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_nav_router_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

///  description:  WebView基类
class ByHyBaseWebView extends StatefulWidget {
  const ByHyBaseWebView({
    super.key,
    required this.title,
    required this.url,
    this.direction,
    this.closeOnAppLinkPrefix,
  });

  final String title;
  final String url;
  final String? direction;
  final String? closeOnAppLinkPrefix;

  @override
  State<ByHyBaseWebView> createState() => _ByHyBaseWebViewState();
}

class _ByHyBaseWebViewState extends State<ByHyBaseWebView> {
  static const String _reloadInitialPayPageMessage =
      '__RELOAD_INITIAL_PAY_PAGE__';

  late final WebViewController _controller;
  StreamSubscription<Uri?>? _appLinkSubscription;
  int _progressValue = 0;
  bool _isClosingFromAppLink = false;
  bool _isShowingExternalPayWaitingPage = false;
  String? _lastBlockedExternalUrl;
  DateTime? _lastBlockedExternalUrlTime;

  @override
  void initState() {
    super.initState();
    _init();
    _listenPayAppLinkIfNeeded();
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    // 页面销毁时，恢复原始状态栏配置
    if (widget.direction != null) {
      _controller.runJavaScript("document.body.innerHTML = ''");
      _controller.loadRequest(Uri.parse(widget.direction!));
    }
    final cookieManager = WebViewCookieManager();
    cookieManager.clearCookies();

    eventBus.fire(ByHyBaseWebViewCloseEvent(title: widget.title));
    super.dispose();
  }

  void _listenPayAppLinkIfNeeded() {
    final String? prefix = widget.closeOnAppLinkPrefix;
    if (prefix == null || prefix.isEmpty) {
      return;
    }

    final appLinks = AppLinks();
    _appLinkSubscription = appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri == null) {
        return;
      }
      final String appLink = uri.toString();
      if (!appLink.startsWith(prefix) || _isClosingFromAppLink || !mounted) {
        return;
      }

      _isClosingFromAppLink = true;
      Navigator.of(context).pop(appLink);
    });
  }

  void _init() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterJs',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == _reloadInitialPayPageMessage) {
            unawaited(_reloadInitialPayPage());
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message.message)));
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            if (_isHttpRequest(request.url)) {
              return NavigationDecision.navigate;
            }

            if (_shouldBlockRepeatedExternalLaunch(request.url)) {
              return NavigationDecision.prevent;
            }

            final Uri? uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.prevent;
            }

            final bool launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (!launched) {
              return NavigationDecision.prevent;
            }

            if (_shouldShowExternalPayWaitingPage) {
              _lastBlockedExternalUrl = request.url;
              _lastBlockedExternalUrlTime = DateTime.now();
              await _showExternalPayWaitingPage();
            } else {
              unawaited(_controller.goBack());
            }
            return NavigationDecision.prevent;
          },
          onProgress: (int progress) {
            if (!mounted) {
              return;
            }
            setState(() {
              _progressValue = progress;
            });
          },
          onPageStarted: (String url) {
            _scheduleTextScaleLock();
          },
          onPageFinished: (String url) {
            _scheduleTextScaleLock();
          },
        ),
      );
    unawaited(_controller.enableZoom(false));
    //安卓选择文件
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      unawaited(androidController.setTextZoom(100));
      unawaited(androidController.setUseWideViewPort(false));
      androidController.setOnShowFileSelector((FileSelectorParams params) {
        final completer = Completer<List<String>>();
        int maxCount = 1;
        if (params.mode == FileSelectorMode.openMultiple) {
          //多选
          maxCount = 9;
        }
        RequestType? type;
        if (params.acceptTypes.any((type) => type == 'image/*')) {
          //图片
          type = RequestType.image;
        } else if (params.acceptTypes.any((type) => type == 'video/*')) {
          //视频
          type = RequestType.video;
        } else {
          //所有文件
          type = RequestType.common;
        }
        ByCommonUtils.pickAssets(
          context,
          type: type,
          maxCount: maxCount,
          onSelectedCallback: (assets) async {
            List<String> list = [];

            /// 未选择则不处理
            if (assets.isNotEmpty) {
              for (int i = 0; i < assets.length; i++) {
                AssetEntity asset = assets[i];
                if (await asset.exists) {
                  var file = await asset.file;
                  var path = file?.uri.toString();
                  list.add(path!);
                }
              }
            }
            if (!completer.isCompleted) {
              completer.complete(list);
            }
          },
          onCancelCallback: () {
            if (!completer.isCompleted) {
              completer.complete([]);
            }
          },
        );
        return completer.future;
      });
    }
    _controller.loadRequest(Uri.parse(widget.url));
  }

  bool get _shouldShowExternalPayWaitingPage {
    final String? prefix = widget.closeOnAppLinkPrefix;
    return prefix != null && prefix.isNotEmpty;
  }

  bool _isHttpRequest(String url) {
    return url.startsWith('https://') || url.startsWith('http://');
  }

  bool _shouldBlockRepeatedExternalLaunch(String url) {
    if (!_shouldShowExternalPayWaitingPage) {
      return false;
    }

    if (_lastBlockedExternalUrl != url || _lastBlockedExternalUrlTime == null) {
      return false;
    }

    final Duration diff = DateTime.now().difference(
      _lastBlockedExternalUrlTime!,
    );
    return diff.inSeconds < 8;
  }

  Future<void> _showExternalPayWaitingPage() async {
    _isShowingExternalPayWaitingPage = true;
    try {
      await _controller.loadHtmlString('''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
    >
    <style>
      body {
        margin: 0;
        padding: 24px;
        font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", sans-serif;
        background: #ffffff;
        color: #1f2937;
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
        box-sizing: border-box;
      }
      .card {
        width: 100%;
        max-width: 360px;
        padding: 24px 20px;
        border-radius: 16px;
        background: #ffffff;
        border: 1px solid #e5e7eb;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
        box-sizing: border-box;
        text-align: center;
      }
      h1 {
        margin: 0 0 12px;
        font-size: 18px;
        color: #111827;
      }
      p {
        margin: 0;
        font-size: 14px;
        line-height: 1.6;
        color: #4b5563;
      }
      .retry {
        color: #2563eb;
        cursor: pointer;
        text-decoration: none;
        font-weight: 600;
      }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>正在等待支付结果</h1>
      <p>
        已为您打开支付宝。若您取消支付并返回此页，可直接点击
        <span class="retry" onclick="retryPay()">重新支付</span>
        开始支付。
      </p>
    </div>
    <script>
      function retryPay() {
        try {
          FlutterJs.postMessage('$_reloadInitialPayPageMessage');
        } catch (e) {}
      }
    </script>
  </body>
</html>
      ''');
    } catch (_) {}
  }

  Future<void> _reloadInitialPayPage() async {
    _isShowingExternalPayWaitingPage = false;
    _lastBlockedExternalUrl = null;
    _lastBlockedExternalUrlTime = null;
    try {
      await _controller.loadRequest(Uri.parse(widget.url));
    } catch (_) {}
  }

  void _scheduleTextScaleLock() {
    unawaited(_lockWebViewTextScale());
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) {
        return;
      }
      unawaited(_lockWebViewTextScale());
    });
  }

  Future<void> _lockWebViewTextScale() async {
    try {
      await _controller.runJavaScript('''
        (function() {
          try {
            var meta = document.querySelector('meta[name="viewport"]');
            if (!meta) {
              meta = document.createElement('meta');
              meta.name = 'viewport';
              if (document.head) {
                document.head.appendChild(meta);
              }
            }
            if (meta) {
              meta.content =
                'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
            }
          } catch (e) {}

          try {
            var styleId = '__app_text_scale_lock__';
            var style = document.getElementById(styleId);
            if (!style) {
              style = document.createElement('style');
              style.id = styleId;
              style.innerHTML =
                'html, body { -webkit-text-size-adjust: 100% !important; text-size-adjust: 100% !important; zoom: 1 !important; max-width: 100vw !important; overflow-x: hidden !important; }'
                + ' body * { -webkit-text-size-adjust: 100% !important; text-size-adjust: 100% !important; }'
                + ' img, svg, canvas, video { max-width: 100% !important; height: auto !important; }';
              if (document.head) {
                document.head.appendChild(style);
              }
            }
          } catch (e) {}

          try {
            if (document.documentElement) {
              document.documentElement.style.webkitTextSizeAdjust = '100%';
              document.documentElement.style.textSizeAdjust = '100%';
            }
            if (document.body) {
              document.body.style.webkitTextSizeAdjust = '100%';
              document.body.style.textSizeAdjust = '100%';
              document.body.style.zoom = '1';
              document.body.style.maxWidth = '100vw';
              document.body.style.overflowX = 'hidden';
            }
          } catch (e) {}

          try {
            if (!window.__appTextScaleObserver__) {
              window.__appTextScaleObserver__ = new MutationObserver(function() {
                try {
                  if (document.documentElement) {
                    document.documentElement.style.webkitTextSizeAdjust = '100%';
                    document.documentElement.style.textSizeAdjust = '100%';
                    document.documentElement.style.zoom = '1';
                  }
                  if (document.body) {
                    document.body.style.webkitTextSizeAdjust = '100%';
                    document.body.style.textSizeAdjust = '100%';
                    document.body.style.zoom = '1';
                    document.body.style.maxWidth = '100vw';
                    document.body.style.overflowX = 'hidden';
                  }
                } catch (e) {}
              });
              window.__appTextScaleObserver__.observe(
                document.documentElement || document.body,
                { childList: true, subtree: true, attributes: true }
              );
            }
          } catch (e) {}
        })();
      ''');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, p0) async {
        if (_isShowingExternalPayWaitingPage) {
          if (didPop || !context.mounted) return;
          ByNavRouterUtils.goBack(context);
          return;
        }
        if (widget.direction != null) {
          await _controller.runJavaScript("document.body.innerHTML = ''");
          await _controller.loadRequest(Uri.parse(widget.direction!));
        }
        final bool canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          // 网页可以返回时，优先返回上一页
          await _controller.goBack();
          // _controller.
          return;
        }
        // 不管canPop是否为true，onPopInvoked都会调用
        if (didPop) return;

        if (!context.mounted) return;

        ByNavRouterUtils.goBack(context);
      },
      child: Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: widget.title,
          popScop: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          onPop: () async {
            if (_isShowingExternalPayWaitingPage) {
              ByNavRouterUtils.goBack(context);
              return;
            }
            if (widget.direction != null) {
              await _controller.runJavaScript("document.body.innerHTML = ''");
              await _controller.loadRequest(Uri.parse(widget.direction!));
            }
            final bool canGoBack = await _controller.canGoBack();
            if (canGoBack) {
              // 网页可以返回时，优先返回上一页
              await _controller.goBack();
              // _controller.
              return;
            }

            ByNavRouterUtils.goBack(context);
          },
          // actions: [
          //   GestureDetector(
          //     onTap: () {
          //       _showActionSheet();
          //     },
          //     behavior: HitTestBehavior.opaque,
          //     child: Padding(
          //       padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          //       child: Image.asset(
          //         "assets/global/common/icon_more.png",
          //         width: 10,
          //         height: 10,
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_progressValue != 100)
              LinearProgressIndicator(
                value: _progressValue / 100,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /// 弹出操作菜单
  void _showActionSheet() {
    showAdaptiveActionSheet(
      context: context,
      title: ByText.text(
        text: "选择操作",
        fontSize: 14.sp,
        textColor: Colors.black87.withValues(alpha: 0.8),
      ),
      androidBorderRadius: 15.w,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: ByText.text(
            text: '复制链接',
            fontSize: 15.sp,
            textColor: Colors.black87,
          ),
          onPressed: (context) {
            Clipboard.setData(ClipboardData(text: widget.url));
            SnackBar(
              content: ByText.text(
                text: '复制成功',
                fontSize: 15.sp,
                textColor: Colors.black87,
              ),
            );
            Navigator.of(context).pop();
          },
        ),
        BottomSheetAction(
          title: ByText.text(
            text: '外部浏览器打开',
            fontSize: 15.sp,
            textColor: Colors.black87,
          ),
          onPressed: (context) async {
            final navigator = Navigator.of(context);
            final Uri uri = Uri.parse(widget.url);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            navigator.pop();
          },
        ),
      ],
      cancelAction: CancelAction(
        title: ByText.text(
          text: '取消',
          fontSize: 15.sp,
          textColor: Colors.black87,
        ),
      ),
    );
  }
}

class ByHyBaseWebViewCloseEvent {
  final String title;
  const ByHyBaseWebViewCloseEvent({required this.title});
}
