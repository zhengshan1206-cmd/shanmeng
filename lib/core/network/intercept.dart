import '../cache/byhy_aes_storage_utils.dart';
import '../cache/byhy_encrypt_utils.dart';
import '../cache/log_utils.dart';
import 'const_keys.dart';
import 'error_handle.dart';
import 'package:dio/dio.dart';

import 'novel_apis.dart';

///用户默认的token
const String defaultToken = '';

///获取token
String getToken() {
  var token = ByStorageUtils.getString(ConstKeys.kToken) ?? defaultToken;
  return token;
}

///存储token
Future<bool>? setToken(dynamic token) {
  return ByStorageUtils.saveString(ConstKeys.kToken, token);
}

///获取新token
String getRefreshToken() {
  var refreshToken = ByStorageUtils.getString('refreshToken') ?? '';
  return refreshToken;
}

///存储新token
void setRefreshToken(dynamic refreshToken) {
  ByStorageUtils.saveString('refreshToken', refreshToken);
}

/// 统一添加身份验证请求头（根据项目自行处理）
class AuthInterceptor extends Interceptor {
  String _getSign(int timestamp) {
    final token = ByAESStorageUtils.getString(ConstKeys.kToken) ?? "";
    final sign = ByEncryptUtils.md5String("$timestamp$token");
    return sign;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path != NovelApis.launch) {
      final String token = getToken();
      if (token.isNotEmpty) {
        LogUtils.e("update token: $token", tag: "OnRequest:");
        final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000)
            .floor();
        options.headers[ConstKeys.kToken] = getToken();
        options.headers[ConstKeys.kTimeStamp] = timestamp;
        options.headers[ConstKeys.kSign] = _getSign(timestamp);
      }
      super.onRequest(options, handler);
    }
  }
}

/// 打印日志
class LoggingInterceptor extends Interceptor {
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    LogUtils.d('-------------------- Start --------------------');
    if (options.queryParameters.isEmpty) {
      LogUtils.d('RequestUrl: ${options.baseUrl}${options.path}');
    } else {
      LogUtils.d(
        'RequestUrl: ${options.baseUrl}${options.path}?${Transformer.urlEncodeMap(options.queryParameters)}',
      );
    }
    LogUtils.d('RequestMethod: ${options.method}');
    LogUtils.d('RequestHeaders:${options.headers}');
    LogUtils.d('RequestContentType: ${options.contentType}');
    LogUtils.d('RequestData: ${options.data.toString()}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _endTime = DateTime.now();
    final int duration = _endTime.difference(_startTime).inMilliseconds;
    if (response.statusCode == ExceptionHandle.success) {
      LogUtils.d('ResponseCode: ${response.statusCode}');
    } else {
      LogUtils.e('ResponseCode: ${response.statusCode}');
    }
    // 输出结果
    LogUtils.d('返回数据：${response.data}');
    LogUtils.d('-------------------- End: $duration 毫秒 --------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LogUtils.d('-------------------- Error --------------------');
    super.onError(err, handler);
  }
}
