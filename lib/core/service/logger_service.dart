/*
 * @Author: duncy
 * @Date: 2025-12-04 14:47:25
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-12-04 15:03:40
 * @FilePath: /novel_oversea/lib/core/service/logger_service.dart
 * @Description: 
 */

import 'dart:async';
import 'package:dio/dio.dart';

import '../cache/build_config.dart';
import '../util/by_device_info_utils.dart';


class LoggerService {

  static final Dio _dio = Dio()
    ..options.baseUrl = BuildConfig.instance.environment.domain
    ..options.connectTimeout = const Duration(seconds: 10)
    ..options.headers = {
      "Content-Type": "application/json; charset=utf-8",
    };

  static Future<Map<String, dynamic>> sendLog({
    required String tag,
    required String log,
    required String url,
  }) async {
    try {
      final imei = await ByDeviceInfoUtils.deviceInfo();
      final Response response = await _dio.post(
        url,
        data: {"uuid": imei.item2, "tag": tag, "log": log},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print("Dio 错误：${e.message}");
      return {
        "status": e.response?.statusCode ?? -1,
        "message": e.message ?? "未知错误",
      };
    }
  }
}