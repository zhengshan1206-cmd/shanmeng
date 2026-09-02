/*
 * @Author: duncy
 * @Date: 2026-04-14 11:55:19
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-09 11:24:21
 * @FilePath: /ling_bao/lib/global/other/right_manager.dart
 * @Description: 
 */

import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';

class RightBean {
  int? isTest;
  int? testCount;
  int? freeCount;
  int? maxFreeCount;
  int? freeIntergral;
  int? textLength;
  int? voiceLength;
  int? currentIntegral;
  int? configIntegral;
  String? show;
  int? userIntegral;
  int? vipLevel;
  String? vipLevelText;

  RightBean({
    this.isTest,
    this.testCount,
    this.configIntegral,
    this.currentIntegral,
    this.freeCount,
    this.freeIntergral,
    this.maxFreeCount,
    this.show,
    this.textLength,
    this.userIntegral,
    this.vipLevel,
    this.vipLevelText,
    this.voiceLength,
  });

  factory RightBean.fromJson(Map<String, dynamic> json) => RightBean(
    isTest: json["is_test"],
    testCount: json["test_count"] ?? 0,
    freeCount: json['free_count'] ?? 0,
    maxFreeCount: json['maxFreeCount'],
    freeIntergral: json['free_intergral'],
    textLength: json["textLength"],
    voiceLength: json["voiceLength"],
    currentIntegral: json['currentIntegral'],
    configIntegral: json['configIntegral'],
    show: json['show'],
    userIntegral: json["user_integral"],
    vipLevel: json["vip_level"],
    vipLevelText: json['vip_level_text'],
  );
}

class RightManager {
  /// 获取权益接口
  static Future<void> fetchRights({
    required String type,
    required Function(RightBean) onSuccess,
  }) async {
    HttpUtils.post(
      APIs.rights,
      {'type': type},
      showMsgWhenFailed: false,
      success: (data) {
        print('______权益:type-$type-$data');
        RightBean bean = RightBean.fromJson(data['data']);
        onSuccess.call(bean);
      },
      fail: (code, msg) {},
    );
  }
}
