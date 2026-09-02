/// 通用接口响应包裹对象。
///
/// 当前后端约定使用 `status/message/data` 结构，因此在这里统一解析。
class ApiResponse<T> {
  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final T data;

  bool get isSuccess => status == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) mapData,
  ) {
    return ApiResponse<T>(
      status: json['status'] is int ? json['status'] as int : 0,
      message: json['message']?.toString() ?? '',
      data: mapData(json['data']),
    );
  }
}
