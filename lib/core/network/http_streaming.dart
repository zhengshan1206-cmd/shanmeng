import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import "package:http/http.dart" as http;
import 'package:ling_bao/core/cache/build_config.dart';

import '../cache/byhy_aes_storage_utils.dart';
import '../cache/byhy_encrypt_utils.dart';
import '../ui/dialog/toast.dart';
import '../util/extentions.dart';
import 'const_keys.dart';
import 'intercept.dart';
import 'result.dart';

class HttpSteaming {
  ///流式消息订阅
  StreamSubscription<String>? messageSubscription;

  ///网络连接状态监听
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool isGenerating = false;

  void init() {
    startListening();
    messageSubscription?.cancel();
    isGenerating = true;
  }

  void dispose() {
    _subscription?.cancel();
    isGenerating = false;
    messageSubscription?.cancel();
  }

  // 初始化监听
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  // 处理网络变化
  void _handleConnectivityChange(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      if (isGenerating) {
        Toast.showText(text: 'Network disconnected, streaming is pausing!');
      }
    } else {
      // 恢复在线功能
    }
  }

  ///获取流式内容
  void fetchContentGeneration(
    dynamic params,
    String url, {
    void Function(String)? streaming,
    void Function()? complete,
    void Function(String)? error,
  }) async {
    init();
    final stream = await getStream(
      url: BuildConfig.instance.environment.domain + url,
      body: params,
    );
    messageSubscription = stream.listen(
      (data) {
        streaming?.call(data);
      },
      onDone: () {
        print('流式输出完成________=====>>>>>');
        complete?.call();
        dispose();
      },
      onError: (e) {
        if (e is APIError) {
          Toast.showText(text: e.message);
          error?.call(e.message);
          dispose();
        }
      },
    );
  }

  Future<Stream<String>> getStream({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final controller = StreamController<String>();
    final uri = Uri.parse(url);

    final request = http.Request('POST', uri);
    _updateHeaders(request);

    if (body != null && body.isNotEmpty) {
      request.bodyFields = body.convertMap();
    }
    request.send().then((http.StreamedResponse response) async {
      // 处理响应
      if (response.statusCode == 200) {
        await for (String chunk in response.stream.transform(utf8.decoder)) {
          controller.add(chunk);
        }
        controller.close();
      } else {
        controller.addError(
          APIError(response.reasonPhrase ?? '', response.statusCode),
        );
      }
    });

    return controller.stream;
  }

  void _updateHeaders(http.Request request) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    request.headers[ConstKeys.kToken] = getToken();
    request.headers[ConstKeys.kClientType] = "strong";
    request.headers[ConstKeys.kTimeStamp] = timestamp.toString();
    request.headers[ConstKeys.kAppFramework] = 'flutter';
    request.headers[ConstKeys.kAppVersion] =
        ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "1.0.0";
    request.headers[ConstKeys.kSign] = _getSign(timestamp);
  }

  String _getSign(int timestamp) {
    final token = ByAESStorageUtils.getString(ConstKeys.kToken) ?? "";
    final sign = ByEncryptUtils.md5String("$timestamp$token");
    return sign;
  }
}
