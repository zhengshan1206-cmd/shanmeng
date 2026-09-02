// ignore_for_file: avoid_print

// 通用 HTTP 客户端。
// 负责拼接基础域名、注入签名请求头、解析标准响应结构，并把错误转换成
// ApiException 抛给上层业务模块。
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'api_response.dart';
import 'device_context.dart';
import 'request_signer.dart';
import 'session_store.dart';

/// 面向业务层的简单网络访问入口。
class ApiClient {
  /// 与旧项目 `launchTest` 保持一致的渠道值。
  static const String launchTestChannel = '9a0c5a33b4c5cba7';

  ApiClient({
    required SessionStore sessionStore,
    required DeviceContext deviceContext,
  }) : _sessionStore = sessionStore,
       _deviceContext = deviceContext,
       _dio = Dio(
         BaseOptions(
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           sendTimeout: const Duration(seconds: 10),
           responseType: ResponseType.json,
           contentType: Headers.jsonContentType,
         ),
       );

  final SessionStore _sessionStore;
  final DeviceContext _deviceContext;
  final Dio _dio;

  /// 发送 GET 请求。
  ///
  /// 适用于查询类接口，例如用户信息、套餐列表等。
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool allowAnonymous = false,
    Set<int> acceptedStatuses = const <int>{200},
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      allowAnonymous: allowAnonymous,
      acceptedStatuses: acceptedStatuses,
    );
  }

  /// 发送 POST 请求。
  ///
  /// 适用于登录、下单、轮询等带请求体的业务接口。
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool allowAnonymous = false,
    Set<int> acceptedStatuses = const <int>{200},
  }) {
    return _request(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      allowAnonymous: allowAnonymous,
      acceptedStatuses: acceptedStatuses,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> _request({
    required String method,
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    required bool allowAnonymous,
    required Set<int> acceptedStatuses,
  }) async {
    // 先做本地网络可用性判断，避免无网时直接打到底层 Dio 才报错。
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw ApiException('No network connection available.');
    }

    // 域名支持通过本地缓存切换，便于测试环境和正式环境复用同一套逻辑。
    final baseUrl = _sessionStore.baseUrl;
    if (baseUrl.isEmpty) {
      throw ApiException('Base URL is empty. Save a valid API host first.');
    }

    final headers = _buildHeaders(allowAnonymous: allowAnonymous);
    try {
      _emitLog(
        'ApiClient request: '
        'method=$method path=$path query=$queryParameters data=$data',
      );
      final response = await _dio.request<dynamic>(
        '$baseUrl$path',
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers),
      );
      _emitLog(
        'ApiClient response: '
        'method=$method path=$path statusCode=${response.statusCode} body=${response.data}',
      );

      // 当前项目假定服务端总是返回标准 JSON 包裹结构。
      if (response.data is! Map<String, dynamic>) {
        throw ApiException('Unexpected response payload type.');
      }

      // 某些接口的 data 可能不是 Map，而是数组或基础类型，这里统一兜成
      // Map，方便上层仍然沿用同一种读取方式。
      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (dynamic payload) {
          if (payload is Map<String, dynamic>) {
            return payload;
          }
          return <String, dynamic>{'_value': payload};
        },
      );

      if (!acceptedStatuses.contains(envelope.status)) {
        throw ApiException(
          envelope.message.isEmpty ? 'Request failed.' : envelope.message,
          code: envelope.status,
        );
      }

      return envelope;
    } on DioException catch (error) {
      _emitLog(
        'ApiClient error: '
        'method=$method path=$path statusCode=${error.response?.statusCode} '
        'response=${error.response?.data} message=${error.message}',
      );
      // 将第三方网络异常收敛成业务层统一可展示的错误类型。
      throw ApiException(
        error.message ?? 'Network request failed.',
        code: error.response?.statusCode,
        cause: error,
      );
    }
  }

  /// 构建接口请求头。
  ///
  /// 这里统一补齐渠道、时间戳、设备语言、token 与签名，业务层不再重复关心。
  Map<String, String> _buildHeaders({required bool allowAnonymous}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final token = allowAnonymous ? '' : _sessionStore.token;

    return <String, String>{
      'accept': 'application/json,*/*',
      'content-type': 'application/json',
      'channel': launchTestChannel,
      'token': token,
      'client_type': 'strong',
      'timestamp': '$timestamp',
      'app_framework': 'flutter',
      'app_version': _deviceContext.appVersion,
      'accept-language': _deviceContext.languageCode,
      'user_language': _deviceContext.languageCode,
      'local_country': _deviceContext.countryCode,
      'user-agent': _deviceContext.userAgent,
      'sign': RequestSigner.sign(timestampSeconds: timestamp, token: token),
    };
  }

  void _emitLog(String message) {
    developer.log(message, name: 'ApiClient');
    print(message);
  }
}
