/// 统一的网络异常对象。
///
/// 用于把 Dio、业务状态码和本地校验错误收敛成一个可展示的错误类型。
class ApiException implements Exception {
  ApiException(this.message, {this.code, this.cause});

  final String message;
  final int? code;
  final Object? cause;

  @override
  String toString() {
    if (code == null) {
      return message;
    }
    return '[$code] $message';
  }
}
