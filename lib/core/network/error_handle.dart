/*
 * @Author: duncy
 * @Date: 2025-06-04 09:23:19
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-14 09:56:51
 * @FilePath: /ling_bao/lib/core/network/error_handle.dart
 * @Description: 
 */
library;
import 'dart:io';
import 'package:dio/dio.dart';

///  description:  异常处理
class ExceptionHandle {
  static const int success = 200; // 请求成功的状态码
  static const int successNotContent = 204;
  static const int notModified = 304;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;

  static const int netError = 1000;
  static const int parseError = 1001;
  static const int socketError = 1002;
  static const int httpError = 1003;
  static const int connectTimeoutError = 1004;
  static const int sendTimeoutError = 1005;
  static const int receiveTimeoutError = 1006;
  static const int cancelError = 1007;
  static const int unknownError = 9999;

  static final Map<int, NetError> _errorMap = <int, NetError>{
    netError: NetError(netError, '错误，请检查您的网络'),
    parseError: NetError(parseError, '数据解析异常'),
    socketError: NetError(socketError, '错误，请检查您的网络'),
    httpError: NetError(httpError, '服务器异常，请稍后重试'),
    connectTimeoutError: NetError(connectTimeoutError, '连接超时'),
    sendTimeoutError: NetError(sendTimeoutError, '请求超时'),
    receiveTimeoutError: NetError(receiveTimeoutError, '相应超时'),
    cancelError: NetError(cancelError, '取消请求'),
    unknownError: NetError(unknownError, '错误，请检查您的网络'),
  };

  static NetError handleException(dynamic error) {
    if (error is DioException) {
      if (error.type.errorCode == 0) {
        return _handleException(error.error);
      } else {
        return _errorMap[error.type.errorCode]!;
      }
    } else {
      return _handleException(error);
    }
  }

  static NetError _handleException(dynamic error) {
    int errorCode = unknownError;
    if (error is SocketException) {
      errorCode = socketError;
    }
    if (error is HttpException) {
      errorCode = httpError;
    }
    if (error is FormatException) {
      errorCode = parseError;
    }
    return _errorMap[errorCode]!;
  }
}

class NetError {
  int code;
  String msg;

  NetError(this.code, this.msg);
}

extension DioErrorTypeExtension on DioExceptionType {
  int get errorCode => [
    ExceptionHandle.connectTimeoutError,
    ExceptionHandle.sendTimeoutError,
    ExceptionHandle.receiveTimeoutError,
    0,
    ExceptionHandle.cancelError,
    0,
    0,
    0,
    0,
    0,
    0,
  ][index];
}