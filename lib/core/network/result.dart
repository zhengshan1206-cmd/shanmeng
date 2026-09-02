/*
 * @Author: cold-x
 * @Date: 2025-06-11 13:35:45
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-25 10:06:35
 * @FilePath: /novel_oversea/lib/core/network/result.dart
 * @Description: 
 */
class Result<T, E extends Error> {
  T? responseData;
  E? error;

  Result._(this.responseData, this.error);

  factory Result.succss(T data) {
    return Result._(data, null);
  }

  factory Result.failure(
    E error, {
    T? responseData,
  }) {
    return Result._(responseData, error);
  }

  bool get isSuccess => error == null;
  bool get isFailure => !isSuccess;
  //暂时这么判断
  bool get isTimeout => responseData == null && error != null;
}

class APIError implements Error {
  final String message;

  /// The status code of the request that failed, if any.
  final int code;

  /// {@macro request_failure}
  APIError(this.message, this.code);

  @override
  String toString() {
    return 'RequestError{message: $message, statusCode: $code}';
  }

  @override
  StackTrace? get stackTrace => null;
}
