// ignore_for_file: avoid_print

import '../cache/build_config.dart';
import '../cache/log_utils.dart';
import '../../global/attribution/by_ascribe_util.dart';
import '../ui/dialog/loading_dialog.dart';
import '../ui/dialog/toast.dart';
import '../ui/view/by_common_utils.dart';
import 'intercept.dart';
import 'dio_utils.dart';
import 'error_handle.dart';
import 'package:dio/dio.dart';

typedef Success<T> = Function(T data);
typedef Fail = Function(int code, String msg);

// 日志开关
const bool isOpenLog = true;

class HttpUtils {
  /// dio main函数初始化
  static void initDio() {
    ///拦截器集合
    final List<Interceptor> interceptors = <Interceptor>[];

    /// 统一添加身份验证请求头
    interceptors.add(AuthInterceptor());

    ///打印日志拦截器
    interceptors.add(LoggingInterceptor()); // 调试打开
    configDio(
      baseUrl: BuildConfig.instance.environment.domain,
      interceptors: interceptors,
    );
  }

  ///设置基本请求url
  static void setBaseUrl(String baseUrl) {
    DioUtils.instance.dio.options.baseUrl = baseUrl;
  }

  /// get请求
  static Future get<T>(
    String url,
    Map<String, dynamic>? params, {
    String? loadingText,
    Success? success,
    bool showLoading = false,
    CancelToken? cancelToken,
    bool forceData = false,
    bool showMsgWhenFailed = true,
    Fail? fail,
  }) async {
    await request(
      Method.get,
      url,
      params,
      forceData: forceData,
      showMsgWhenFailed: showMsgWhenFailed,
      loadingText: loadingText,
      cancelToken: cancelToken,
      showLoading: showLoading,
      success: success,
      fail: fail,
    );
  }

  /// post 请求
  static Future post<T>(
    String url,
    params, {
    String? loadingText,
    bool showLoading = false,
    Options? options,
    CancelToken? cancelToken,
    bool forceData = false,
    bool showMsgWhenFailed = true,
    Success? success,
    Fail? fail,
  }) async {
    await request(
      Method.post,
      url,
      params,
      forceData: forceData,
      showMsgWhenFailed: showMsgWhenFailed,
      loadingText: loadingText,
      showLoading: showLoading,
      cancelToken: cancelToken,
      success: success,
      fail: fail,
    );
  }

  /// 轮询请求方法
  /// [method] - 请求方法(GET/POST)
  /// [url] - 请求地址
  /// [data] - POST请求数据
  /// [queryParameters] - GET请求参数
  /// [checkSuccess] - 检查响应是否成功的回调
  /// [onSuccess] - 成功回调
  /// [onError] - 错误回调
  /// [cancelToken] - 取消令牌
  /// [maxAttempts] - 最大尝试次数,默认无限循环
  static Future<void> startPolling({
    required Method method,
    required String url,
    params,
    Map<String, dynamic>? queryParameters,
    required bool Function(dynamic response) checkSuccess,
    Function(dynamic response)? onSuccess,
    Function(int code, String msg)? onError,
    CancelToken? cancelToken,
    int currentAttempts = 0,
    int? maxAttempts,
  }) async {
    if (maxAttempts == null || currentAttempts < maxAttempts) {
      Object? data;
      if (method == Method.get) {
        queryParameters = params;
      }
      if (method == Method.post) {
        data = params;
      }
      try {
        await DioUtils.instance.request(
          method,
          url,
          data: data,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onSuccess: (response) {
            if (checkSuccess(response)) {
              onSuccess?.call(response);
              return;
            }
            _retryAfterDelay(
              method: method,
              url: url,
              data: params,
              queryParameters: queryParameters,
              checkSuccess: checkSuccess,
              onSuccess: onSuccess,
              onError: onError,
              cancelToken: cancelToken,
              maxAttempts: maxAttempts,
              currentAttempts: currentAttempts + 1,
            );
          },
          onError: (code, msg) {
            onError?.call(code, msg);
            _retryAfterDelay(
              method: method,
              url: url,
              data: params,
              queryParameters: queryParameters,
              checkSuccess: checkSuccess,
              onSuccess: onSuccess,
              onError: onError,
              cancelToken: cancelToken,
              maxAttempts: maxAttempts,
              currentAttempts: currentAttempts + 1,
            );
          },
        );
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) return;
        _retryAfterDelay(
          method: method,
          url: url,
          data: data,
          queryParameters: queryParameters,
          checkSuccess: checkSuccess,
          onSuccess: onSuccess,
          onError: onError,
          cancelToken: cancelToken,
          maxAttempts: maxAttempts,
          currentAttempts: currentAttempts + 1,
        );
      }
    }
  }

  /// 轮询间隔
  static const int _pollingInterval = 3000;

  /// 轮询请求重试
  static void _retryAfterDelay({
    required Method method,
    required String url,
    required Object? data,
    required Map<String, dynamic>? queryParameters,
    required bool Function(dynamic) checkSuccess,
    required Function(dynamic)? onSuccess,
    required Function(int code, String msg)? onError,
    required CancelToken? cancelToken,
    required int? maxAttempts,
    required int currentAttempts,
  }) {
    Future.delayed(
      const Duration(milliseconds: _pollingInterval),
      () => startPolling(
        method: method,
        url: url,
        params: data,
        queryParameters: queryParameters,
        checkSuccess: checkSuccess,
        onSuccess: onSuccess,
        onError: onError,
        cancelToken: cancelToken,
        maxAttempts: maxAttempts,
      ),
    );
  }

  /// _request请求 默认不展示loading
  static Future request<T>(
    Method method,
    String url,
    params, {
    bool showLoading = false,
    CancelToken? cancelToken,
    String? loadingText = 'loading...',
    Success? success,
    required bool forceData,
    required bool showMsgWhenFailed,
    Fail? fail,
    Options? options,
  }) async {
    ///参数处理（如果需要加密等统一参数）
    if (!LogUtils.inProduction && isOpenLog) {
      byDebugPrint('---------- HttpUtils URL ----------$showLoading');
      byDebugPrint(url);
      byDebugPrint('---------- HttpUtils params ----------$showLoading');
      byDebugPrint(_buildDebugParams(params));
    }

    Object? data;
    Map<String, dynamic>? queryParameters;
    if (method == Method.get) {
      queryParameters = params;
    }
    if (method == Method.post) {
      data = params;
    }
    if (showLoading == true) {
      LoadingDialog().show(message: loadingText);
    }

    DioUtils.instance.request(
      method,
      url,
      data: data,
      options: options,
      cancelToken: cancelToken,
      queryParameters: queryParameters,
      onSuccess: (result) {
        if (!LogUtils.inProduction && isOpenLog) {
          byDebugPrint('---------- HttpUtils response ----------$url');
          byDebugPrint(result);
        }
        if (result is! Map) {
          fail?.call(400, 'Data parsing error');
          return;
        }
        if (result.containsKey('byuniplugin')) {
          final byunipluginValue = result['byuniplugin'];
          try {
            List<dynamic>? pluginList;
            if (byunipluginValue is List) {
              pluginList = byunipluginValue;
            } else if (byunipluginValue is Map) {
              pluginList = [byunipluginValue];
            } else {
              byDebugPrint(
                'byuniplugin 类型不支持，期望 List 或 Map，实际类型: ${byunipluginValue.runtimeType}',
                tag: '[HTTP]',
              );
            }
            if (pluginList != null) {
              ByAscribeUtil.byuniplugin(pluginList);
            }
          } catch (e) {
            byDebugPrint('处理 byuniplugin 时发生错误: $e', tag: '[HTTP]');
          }
        }
        if (showLoading == true) {
          LoadingDialog().dismiss();
        }
        if (result['status'] == ExceptionHandle.success) {
          success?.call(result);
        } else if (result['status'] == ResponseCode.loginRequired) {
          ///todo 这里需要做重新登录
          fail?.call(result['status'] ?? result["code"], result['message']);
        } else if (result['status'] == ResponseCode.vipPromote) {
          fail?.call(result['status'] ?? result["code"], result['message']);
        } else if (result['status'] == ResponseCode.pointsNotEnough) {
          ///积分不足
          fail?.call(result['status'] ?? result["code"], result['message']);
        } else if (forceData) {
          success?.call(result);
        } else {
          ///其他状态，弹出错误提示信息
          if (showMsgWhenFailed) {
            Toast.showText(text: result['message']);
          }
          fail?.call(result['status'] ?? result["code"], result['message']);
        }
      },
      onError: (code, msg) {
        if (showLoading == true) {
          LoadingDialog().dismiss();
          Toast.showText(text: msg);
        }
        fail?.call(code, msg);
      },
    );
  }

  static Object? _buildDebugParams(dynamic params) {
    if (params is! FormData) {
      return params;
    }
    return <String, dynamic>{
      'type': 'FormData',
      'fields': params.fields
          .map((entry) => <String, dynamic>{entry.key: entry.value})
          .toList(),
      'files': params.files
          .map(
            (entry) => <String, dynamic>{
              'key': entry.key,
              'filename': entry.value.filename,
              'contentType': entry.value.contentType?.toString(),
            },
          )
          .toList(),
    };
  }
}

class ResponseCode {
  /// vip特价弹窗
  static int vipPromote = 1002;

  /// 未登录
  static int loginRequired = 2001;

  /// 积分不足
  static int pointsNotEnough = 1000001;
}
