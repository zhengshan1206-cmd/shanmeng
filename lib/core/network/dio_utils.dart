import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ling_bao/core/network/const_keys.dart';
import 'dart:convert';
import '../cache/build_config.dart';
import '../cache/byhy_aes_storage_utils.dart';
import '../cache/byhy_encrypt_utils.dart';
import '../cache/log_utils.dart';
import '../util/by_device_info_utils.dart';
import 'error_handle.dart';
import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'intercept.dart';
import 'package:flutter/services.dart';
import 'package:fk_user_agent/fk_user_agent.dart';

import 'novel_apis.dart';

class UserAgentUtil {
  // 定义原生通道名称（需与原生代码一致）
  // static const MethodChannel _methodchannel = MethodChannel('com.by.ve.bridge');

  // 获取设备User-Agent
  static Future<String?> getUserAgent() async {
    await FkUserAgent.init();
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = Platform.isIOS
          ? FkUserAgent.webViewUserAgent!
          : FkUserAgent.userAgent!;
    } on PlatformException catch (e) {
      platformVersion = 'Failed to get platform version.${e.message}';
    }
    return platformVersion;
    // try {
    //   // 调用原生方法
    //   final String? userAgent =
    //       await _methodchannel.invokeMethod('getUserAgent');
    //   return userAgent;
    // } on PlatformException catch (e) {
    //   print('_____获取User-Agent失败: ${e.message}');
    //   return null;
    // }
  }
}

/// 默认dio配置 根据项目实际需求更改
String _channel = BuildConfig.instance.channelType.channel;
String _baseUrl = BuildConfig.instance.environment.domain;
Duration _connectTimeout = const Duration(seconds: 15);
Duration _receiveTimeout = const Duration(seconds: 15);
Duration _sendTimeout = const Duration(seconds: 10);
List<Interceptor> _interceptors = [];

typedef NetSuccessCallback<T> = Function(T data);
typedef NetSuccessListCallback<T> = Function(List<T> data);
typedef NetErrorCallback = Function(int code, String msg);

/// 初始化Dio配置
void configDio({
  Duration? connectTimeout,
  Duration? receiveTimeout,
  Duration? sendTimeout,
  String? baseUrl,
  List<Interceptor>? interceptors,
}) {
  _connectTimeout = connectTimeout ?? _connectTimeout;
  _receiveTimeout = receiveTimeout ?? _receiveTimeout;
  _sendTimeout = sendTimeout ?? _sendTimeout;
  _baseUrl = baseUrl ?? _baseUrl;
  _interceptors = interceptors ?? _interceptors;
}

///网络层dio-请求工具
class DioUtils {
  factory DioUtils() => _singleton;

  DioUtils._() {
    ///全局属性：请求前缀、连接超时时间、响应超时时间
    final BaseOptions options = BaseOptions(
      /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
      /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
      /// 可以设置此选项为 “Headers.formUrlEncodedContentType”,  这样[Dio]就会自动编码请求体.
      /// contentType: Headers.formUrlEncodedContentType, // 适用于post form表单提交
      responseType: ResponseType.json,
      validateStatus: (status) {
        ///不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },
      baseUrl: _baseUrl,
      headers: _httpHeaders,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
    );
    _dio = Dio(options);

    // /// Fiddler抓包代理配置
    // dio.httpClientAdapter = IOHttpClientAdapter(
    //   createHttpClient: () {
    //     final client = HttpClient();
    //     client.findProxy = (uri) {
    //       // 将请求代理至 localhost:8888。
    //       // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
    //       return 'PROXY 192.168.3.165:8888';
    //     };
    //     // 抓Https包设置
    //     client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //     return client;
    //   },
    // );

    /// 测试环境忽略证书校验
    ///
    var isTest =
        !LogUtils.inProduction ||
        BuildConfig.instance.environment.domain.startsWith('https://192');
    if (isTest) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    /// 添加拦截器
    void addInterceptor(Interceptor interceptor) {
      _dio.interceptors.add(interceptor);
    }

    _interceptors.forEach(addInterceptor);
  }

  static final DioUtils _singleton = DioUtils._();

  static DioUtils get instance => DioUtils();

  static late Dio _dio;

  Dio get dio => _dio;

  Future request<T>(
    Method method,
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    NetSuccessCallback? onSuccess,
    NetErrorCallback? onError,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      ///检查是否有网络链接
      var connectivityResult = await (Connectivity().checkConnectivity());
      // ignore: unrelated_type_equality_checks
      if (connectivityResult == ConnectivityResult.none) {
        _onError(
          ExceptionHandle.netError,
          '错误，请检查您的网络',
          onError,
        );
        return;
      }

      ///是否是启动接口
      bool isLoginToken = false;
      if (url == NovelApis.launch) {
        isLoginToken = true;
      }
      _updateHeaders(isLoginToken: isLoginToken);
      _updateUserAgent();
      final Response response = await _dio.request<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _checkOptions(_methodValues[method], options),
        cancelToken: cancelToken,
      );

      ///请求成功的回调
      onSuccess?.call(response.data);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
      } else {
        _cancelLogPrint(e, url);
        final NetError error = ExceptionHandle.handleException(e);
        _onError(error.code, error.msg, onError);
      }
    }
  }

  Future<void> _updateUserAgent() async {
    final String? userAgent = await UserAgentUtil.getUserAgent();
    if (userAgent == null) {
      _dio.options.headers[ConstKeys.kUserAgent] = ConstKeys.userAgentData;
    }
    _dio.options.headers[ConstKeys.kUserAgent] = userAgent;
  }

  void _updateHeaders({bool isLoginToken = false}) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final token = isLoginToken ? '' : getToken();
    _dio.options.headers[ConstKeys.kToken] = token;
    _dio.options.headers[ConstKeys.kClientType] = "strong";
    _dio.options.headers[ConstKeys.kTimeStamp] = timestamp;
    _dio.options.headers[ConstKeys.kAppFramework] = 'flutter';
    _dio.options.headers[ConstKeys.kAcceptLanguage] = 'en';
    _dio.options.headers[ConstKeys.kPosition] = ByDeviceInfoUtils.getPosition();
    _dio.options.headers[ConstKeys.kTimeZone] = ByDeviceInfoUtils.getTimeZone();
    // _dio.options.headers[ConstKeys.kLocalCountry] =
    //     ByDeviceInfoUtils.getCountryFromLocale();
    // _dio.options.headers[ConstKeys.kUserLanguage] =
    //     ByDeviceInfoUtils.getLanguageFromLocale();
    // _dio.options.headers[ConstKeys.kIpCountry] =
    //     ByDeviceInfoUtils.getIpCountry();
    _dio.options.headers[ConstKeys.kAppVersion] =
        ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "1.0.0";
    _dio.options.headers[ConstKeys.kSign] = _getSign(timestamp, token);
  }
}

Options _checkOptions(String? method, Options? options) {
  options ??= Options();
  options.method = method;
  return options;
}

void _cancelLogPrint(dynamic e, String url) {
  if (e is DioException && CancelToken.isCancel(e)) {
    LogUtils.e('取消请求接口： $url');
  }
}

void _onError(int? code, String msg, NetErrorCallback? onError) {
  if (code == null) {
    code = ExceptionHandle.unknownError;
    msg = 'unknown error';
  }
  LogUtils.e('接口请求异常： code: $code, mag: $msg');
  onError?.call(code, msg);
}

/// 自定义Header
Map<String, dynamic> _httpHeaders = {
  ConstKeys.kAccept: 'application/json,*/*',
  ConstKeys.kContentType: 'application/json',
  ConstKeys.kChannel: _channel,
};

String _getSign(int timestamp, String token) {
  final sign = ByEncryptUtils.md5String("$timestamp$token");
  return sign;
}

Map<String, dynamic> parseData(String data) {
  return json.decode(data) as Map<String, dynamic>;
}

enum Method { get, post, put, patch, delete, head }

/// 使用：_methodValues[Method.post]
const _methodValues = {
  Method.get: 'get',
  Method.post: 'post',
  Method.delete: 'delete',
  Method.put: 'put',
  Method.patch: 'patch',
  Method.head: 'head',
};
