// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/core/ui/view/by_common_utils.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class BankCardSignWebViewPage extends StatefulWidget {
  const BankCardSignWebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.postFields,
  });

  final String title;
  final String url;
  final Map<String, String>? postFields;
  static const String successResult = '__bank_sign_success__';

  @override
  State<BankCardSignWebViewPage> createState() =>
      _BankCardSignWebViewPageState();
}

class _BankCardSignWebViewPageState extends State<BankCardSignWebViewPage> {
  static const String _defaultJsChannelName = 'FlutterJs';
  static const String _closeMethodName = 'bfCloseH5';
  static const List<String> _baofuChannelNames = <String>[
    'androidYZH',
    'nativejs',
  ];

  late final WebViewController _controller;
  int _progressValue = 0;
  bool _isClosing = false;
  int _bridgeInjectEpoch = 0;
  bool _bridgeInjectRunning = false;
  String _lastObservedUrl = '';

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void dispose() {
    _logWebView('dispose');
    super.dispose();
  }

  void _logWebView(String event, [Object? details]) {
    final String message = details == null ? event : '$event: $details';
    byDebugPrint(message, tag: 'bank_sign_h5');
  }

  void _rememberObservedUrl(String? url) {
    final String normalizedUrl = url?.trim() ?? '';
    if (normalizedUrl.isEmpty) {
      return;
    }
    _lastObservedUrl = normalizedUrl;
  }

  Future<void> _init() async {
    _logWebView('init', 'url=${widget.url}');
    _rememberObservedUrl(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        _defaultJsChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final bool isInternal = _isInternalNavigation(request.url);
            _rememberObservedUrl(request.url);
            _logWebView(
              'navigation_request',
              'url=${request.url}, isMainFrame=${request.isMainFrame}, '
                  'isInternal=$isInternal',
            );
            if (isInternal) {
              return NavigationDecision.navigate;
            }
            launchUrl(Uri.parse(request.url));
            return NavigationDecision.prevent;
          },
          onPageStarted: (String url) {
            _rememberObservedUrl(url);
            _logWebView('page_started', url);
            unawaited(_applyWebViewScaleSettings());
          },
          onProgress: (int progress) {
            if (!mounted) {
              return;
            }
            setState(() {
              _progressValue = progress;
            });
          },
          onPageFinished: (String url) async {
            _rememberObservedUrl(url);
            _logWebView('page_finished', url);
            unawaited(_applyWebViewScaleSettings());
            _scheduleBridgeInjection();
          },
          onUrlChange: (UrlChange change) {
            _rememberObservedUrl(change.url);
            _logWebView('url_change', change.url ?? '');
          },
          onHttpError: (HttpResponseError error) {
            _logWebView(
              'http_error',
              'statusCode=${error.response?.statusCode}, '
                  'url=${error.request?.uri}',
            );
          },
          onWebResourceError: (WebResourceError error) {
            _logWebView(
              'resource_error',
              'code=${error.errorCode}, type=${error.errorType}, '
                  'isForMainFrame=${error.isForMainFrame}, '
                  'description=${error.description}, url=${error.url}',
            );
          },
        ),
      );
    for (final String channelName in _baofuChannelNames) {
      _controller.addJavaScriptChannel(
        channelName,
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      );
    }
    await _applyWebViewScaleSettings();
    if (!mounted) {
      return;
    }
    await _loadInitialRequest();
  }

  Future<void> _applyWebViewScaleSettings() async {
    try {
      await _controller.enableZoom(false);
      if (_controller.platform is! AndroidWebViewController) {
        return;
      }
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      await androidController.setTextZoom(100);
      await androidController.setUseWideViewPort(true);
    } catch (_) {
      // Keep the sign flow available even if a device-specific WebView setting fails.
    }
  }

  WebViewWidget _buildWebViewWidget(BuildContext context) {
    PlatformWebViewWidgetCreationParams params =
        PlatformWebViewWidgetCreationParams(
          controller: _controller.platform,
          layoutDirection: Directionality.of(context),
        );

    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params =
          AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
            params,
            displayWithHybridComposition: true,
          );
    }

    return WebViewWidget.fromPlatformCreationParams(params: params);
  }

  Future<void> _loadInitialRequest() async {
    final Map<String, String> postFields = widget.postFields ?? const {};
    if (postFields.isNotEmpty) {
      _logWebView(
        'load_initial_post',
        'url=${widget.url}, fieldCount=${postFields.length}',
      );
      await _controller.loadHtmlString(
        _buildAutoSubmitHtml(action: widget.url, fields: postFields),
        baseUrl: widget.url,
      );
      return;
    }
    _logWebView('load_initial_request', widget.url);
    _rememberObservedUrl(widget.url);
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  String _buildAutoSubmitHtml({
    required String action,
    required Map<String, String> fields,
  }) {
    const HtmlEscape htmlEscape = HtmlEscape(HtmlEscapeMode.attribute);
    final StringBuffer inputs = StringBuffer();
    for (final MapEntry<String, String> entry in fields.entries) {
      inputs.write(
        '<input type="hidden" name="${htmlEscape.convert(entry.key)}" '
        'value="${htmlEscape.convert(entry.value)}" />',
      );
    }
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <title>${htmlEscape.convert(widget.title)}</title>
</head>
<body>
  <form id="baofuSignForm" method="post" action="${htmlEscape.convert(action)}">
    ${inputs.toString()}
  </form>
  <script>
    document.getElementById('baofuSignForm').submit();
  </script>
</body>
</html>
''';
  }

  bool _isInternalNavigation(String url) {
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('about:blank') ||
        url.startsWith('data:') ||
        url.startsWith('file://');
  }

  void _scheduleBridgeInjection() {
    _bridgeInjectEpoch += 1;
    final int epoch = _bridgeInjectEpoch;
    if (!_bridgeInjectRunning) {
      unawaited(_injectBaofuBridge(epoch: epoch));
    }
    const List<int> retryDelays = <int>[350];
    for (final int delay in retryDelays) {
      Future<void>.delayed(Duration(milliseconds: delay), () {
        if (!mounted) {
          return;
        }
        if (epoch != _bridgeInjectEpoch) {
          return;
        }
        if (!_bridgeInjectRunning) {
          unawaited(_injectBaofuBridge(epoch: epoch));
        }
      });
    }
  }

  Future<void> _injectBaofuBridge({required int epoch}) async {
    if (!mounted || epoch != _bridgeInjectEpoch) {
      return;
    }
    if (_bridgeInjectRunning) {
      return;
    }
    _bridgeInjectRunning = true;
    try {
      await _controller
          .runJavaScript('''
        (function() {
          function buildPayload(method, data) {
            return JSON.stringify({
              method: method,
              data: data == null ? '' : String(data)
            });
          }

          function postToChannel(channelName, method, data) {
            try {
              if (window[channelName] &&
                  typeof window[channelName].postMessage === 'function') {
                window[channelName].postMessage(buildPayload(method, data));
                return true;
              }
            } catch (e) {}
            return false;
          }

          function closeH5(data) {
            return postToChannel('androidYZH', 'bfCloseH5', data) ||
                postToChannel('nativejs', 'bfCloseH5', data) ||
                postToChannel('FlutterJs', 'bfCloseH5', data);
          }

          function resolveUniPayload(payload) {
            var target = payload;
            if (target && typeof target === 'object' && 'data' in target) {
              target = target.data;
            }
            if (Array.isArray(target) && target.length > 0) {
              target = target[0];
            }
            if (target && typeof target === 'object') {
              var method = target.method || target.action || target.event || 'bfCloseH5';
              var value = '';
              if ('data' in target && target.data != null) {
                value = target.data;
              } else if ('params' in target && target.params != null) {
                value = target.params;
              } else if ('value' in target && target.value != null) {
                value = target.value;
              }
              return postToChannel('FlutterJs', method, value);
            }
            return closeH5(target);
          }

          window.bfCloseH5 = closeH5;
          window.closeH5 = closeH5;
          window.androidYZH = window.androidYZH || {};
          window.nativejs = window.nativejs || {};
          window.androidYZH.bfCloseH5 = closeH5;
          window.nativejs.bfCloseH5 = closeH5;

          window.uni = window.uni || {};
          window.uni.postMessage = resolveUniPayload;

          window.__baofuOriginalClose__ =
              window.__baofuOriginalClose__ || window.close;
          var originalWindowClose = window.__baofuOriginalClose__;
          window.close = function() {
            var handled = closeH5('');
            if (!handled && typeof originalWindowClose === 'function') {
              try {
                return originalWindowClose();
              } catch (e) {}
            }
            return false;
          };
        })();
      ''')
          .timeout(const Duration(milliseconds: 800));
    } catch (_) {
    } finally {
      _bridgeInjectRunning = false;
    }
  }

  bool _handleJavaScriptMessage(String rawMessage) {
    final Map<String, dynamic>? payload = _decodeJsPayload(rawMessage);
    final dynamic payloadData =
        payload?['data'] ?? payload?['params'] ?? payload?['value'];
    final String method =
        payload?['method']?.toString() ??
        payload?['action']?.toString() ??
        payload?['event']?.toString() ??
        rawMessage.trim();
    if (method != _closeMethodName) {
      return false;
    }
    final Map<String, String> closeResult = _extractCloseResult(
      rawMessage,
      payload,
    );
    final bool isFallbackSuccess = _isFallbackNoticeSuccess(
      method: method,
      payloadData: payloadData,
      closeResult: closeResult,
    );
    final bool isSuccess = _isSignSuccess(closeResult) || isFallbackSuccess;
    final String failureMessage = _resolveFailureMessage(closeResult);
    unawaited(
      _logCloseDiagnostics(
        rawMessage: rawMessage,
        payload: payload,
        payloadData: payloadData,
        closeResult: closeResult,
        isSuccess: isSuccess,
        isFallbackSuccess: isFallbackSuccess,
        failureMessage: failureMessage,
      ),
    );
    if (isSuccess) {
      _closePage(result: BankCardSignWebViewPage.successResult);
      return true;
    }
    if (failureMessage.isNotEmpty) {
      Toast.showText(text: failureMessage);
    }
    _closePage();
    return true;
  }

  Map<String, String> _extractCloseResult(
    String rawMessage,
    Map<String, dynamic>? payload,
  ) {
    final Map<String, String> result = <String, String>{};

    void merge(Map<String, String> values) {
      values.forEach((String key, String value) {
        final String normalizedKey = key.trim().toLowerCase();
        final String normalizedValue = value.trim();
        if (normalizedKey.isEmpty || normalizedValue.isEmpty) {
          return;
        }
        result[normalizedKey] = normalizedValue;
      });
    }

    merge(_stringifyResultMap(payload));

    final dynamic payloadData =
        payload?['data'] ?? payload?['params'] ?? payload?['value'];
    merge(_parseCloseResultData(payloadData));

    if (result.isEmpty) {
      merge(_parseCloseResultData(rawMessage));
    }

    return result;
  }

  Map<String, String> _parseCloseResultData(dynamic value) {
    if (value == null) {
      return <String, String>{};
    }
    if (value is List && value.isNotEmpty) {
      return _parseCloseResultData(value.first);
    }
    if (value is Map) {
      final Map<String, String> result = _stringifyResultMap(value);
      final dynamic nestedValue =
          value['data'] ?? value['params'] ?? value['value'];
      if (nestedValue != null) {
        result.addAll(_parseCloseResultData(nestedValue));
      }
      return result;
    }

    final String rawValue = value.toString().trim();
    if (rawValue.isEmpty) {
      return <String, String>{};
    }

    try {
      return _parseCloseResultData(jsonDecode(rawValue));
    } catch (_) {}

    final Uri? parsedUri = Uri.tryParse(rawValue);
    if (parsedUri != null && parsedUri.hasQuery) {
      return _normalizeResultMap(parsedUri.queryParameters);
    }

    String queryString = rawValue;
    final int questionMarkIndex = queryString.indexOf('?');
    if (questionMarkIndex >= 0 && questionMarkIndex < queryString.length - 1) {
      queryString = queryString.substring(questionMarkIndex + 1);
    }
    if (queryString.startsWith('?')) {
      queryString = queryString.substring(1);
    }
    if (!queryString.contains('=')) {
      return <String, String>{};
    }

    try {
      return _normalizeResultMap(Uri.splitQueryString(queryString));
    } catch (_) {
      final Map<String, String> result = <String, String>{};
      for (final String pair in queryString.split('&')) {
        if (!pair.contains('=')) {
          continue;
        }
        final int separatorIndex = pair.indexOf('=');
        final String key = pair.substring(0, separatorIndex);
        final String value = pair.substring(separatorIndex + 1);
        result[key] = Uri.decodeQueryComponent(value);
      }
      return _normalizeResultMap(result);
    }
  }

  Map<String, String> _stringifyResultMap(dynamic value) {
    if (value is! Map) {
      return <String, String>{};
    }
    final Map<String, String> result = <String, String>{};
    value.forEach((dynamic key, dynamic item) {
      if (key == null || item == null) {
        return;
      }
      result[key.toString()] = item.toString();
    });
    return _normalizeResultMap(result);
  }

  Map<String, String> _normalizeResultMap(Map<String, String> value) {
    final Map<String, String> result = <String, String>{};
    value.forEach((String key, String item) {
      final String normalizedKey = key.trim().toLowerCase();
      final String normalizedValue = item.trim();
      if (normalizedKey.isEmpty || normalizedValue.isEmpty) {
        return;
      }
      result[normalizedKey] = normalizedValue;
    });
    return result;
  }

  bool _isSignSuccess(Map<String, String> result) {
    final String bizRespCode = result['biz_resp_code']?.toUpperCase() ?? '';
    if (bizRespCode.isNotEmpty) {
      return bizRespCode == '0000';
    }

    final String protocolNo = result['protocol_no'] ?? '';
    if (protocolNo.isNotEmpty) {
      return true;
    }

    final String respCode = result['resp_code']?.toUpperCase() ?? '';
    final String bizRespMsg = result['biz_resp_msg'] ?? '';
    return respCode == 'S' && bizRespMsg.contains('成功');
  }

  String _resolveFailureMessage(Map<String, String> result) {
    const List<String> messageKeys = <String>[
      'biz_resp_msg',
      'resp_msg',
      'message',
      'msg',
    ];
    for (final String key in messageKeys) {
      final String value = result[key]?.trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  bool _isFallbackNoticeSuccess({
    required String method,
    required dynamic payloadData,
    required Map<String, String> closeResult,
  }) {
    if (method != _closeMethodName) {
      return false;
    }
    if (_isSignSuccess(closeResult)) {
      return false;
    }
    final String normalizedPayloadData = payloadData?.toString().trim() ?? '';
    if (normalizedPayloadData.isNotEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _logCloseDiagnostics({
    required String rawMessage,
    required Map<String, dynamic>? payload,
    required dynamic payloadData,
    required Map<String, String> closeResult,
    required bool isSuccess,
    required bool isFallbackSuccess,
    required String failureMessage,
  }) async {
    String controllerUrl = _lastObservedUrl;
    try {
      controllerUrl = (await _controller.currentUrl())?.trim() ?? controllerUrl;
    } catch (_) {}

    _rememberObservedUrl(controllerUrl);
    _logWebView('close_message_raw', rawMessage);
    _logWebView('close_message_payload', payload ?? '<null>');
    _logWebView('close_message_payload_data', payloadData ?? '<null>');
    _logWebView('close_message', closeResult);
    _logWebView(
      'close_message_summary',
      'isSuccess=$isSuccess, '
          'isFallbackSuccess=$isFallbackSuccess, '
          'failureMessage=${failureMessage.isEmpty ? '<empty>' : failureMessage}, '
          'currentUrl=${controllerUrl.isEmpty ? '<empty>' : controllerUrl}',
    );
  }

  Map<String, dynamic>? _decodeJsPayload(String rawMessage) {
    try {
      return _normalizePayload(jsonDecode(rawMessage));
    } catch (_) {}
    return null;
  }

  Map<String, dynamic>? _normalizePayload(dynamic payload) {
    if (payload is List && payload.isNotEmpty) {
      return _normalizePayload(payload.first);
    }
    if (payload is Map<String, dynamic>) {
      final dynamic data = payload['data'];
      final bool hasMethod =
          payload['method'] != null ||
          payload['action'] != null ||
          payload['event'] != null;
      if (!hasMethod && data != null) {
        final Map<String, dynamic>? nestedPayload = _normalizePayload(data);
        if (nestedPayload != null) {
          return nestedPayload;
        }
      }
      return payload;
    }
    if (payload is Map) {
      return _normalizePayload(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return null;
  }

  void _closePage({String? result}) {
    if (_isClosing || !mounted) {
      return;
    }
    _isClosing = true;
    _logWebView(
      'close_page',
      'result=${result ?? 'cancel'}, '
          'lastObservedUrl=${_lastObservedUrl.isEmpty ? '<empty>' : _lastObservedUrl}',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    Navigator.of(context).pop(result);
  }

  Future<void> _handlePop() async {
    _logWebView('manual_close_page');
    _closePage();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handlePop();
      },
      child: Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: widget.title,
          popScop: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          onPop: () async {
            await _handlePop();
          },
        ),
        body: Stack(
          children: [
            _buildWebViewWidget(context),
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
}
