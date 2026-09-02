import 'dart:convert';
import 'dart:io';

import 'package:ling_bao/core/common/channel/by_channel_operate.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/global/const/consts.dart';

/// 归因（对齐 fastcreationmaster / Videoclipedit 的 ByAscribeUtil）
class ByAscribeUtil {
  static int oceanengineState = 0;
  static List<Map<String, dynamic>> oceanengineEventList = [];

  static Future<dynamic> iniBDConvert() async {
    dynamic r;
    if (Platform.isAndroid && Consts.oceanEngineAndroidAppId.isNotEmpty) {
      r = await ChannelOperate.initAppConfig(
        Consts.oceanEngineAndroidAppId,
        'channel',
      );
    }
    oceanengineState = 1;
    if (oceanengineEventList.isNotEmpty) {
      for (var i = 0; i < oceanengineEventList.length; i++) {
        oceanengineEvent(oceanengineEventList[i]);
      }
      oceanengineEventList = [];
    }
    return r;
  }

  static void byuniplugin(List<dynamic> list) async {
    for (var i = 0; i < list.length; i++) {
      Map<String, dynamic> item = list[i] as Map<String, dynamic>;
      String method = item['method'] as String;
      Map<String, dynamic> params =
          Map<String, dynamic>.from(item['params'] as Map);
      if (method == 'oceanengineEvent') {
        if (oceanengineState == 0) {
          oceanengineEventList.add(params);
        } else {
          oceanengineEvent(params);
        }
      }
    }
  }

  static void oceanengineEvent(Map<String, dynamic> params) async {
    String url;
    try {
      String jsonString = jsonEncode(params);
      ChannelOperate.oceanengineEvent(jsonString);
      url = APIs.oceanengineSuccess;
    } catch (e) {
      url = APIs.oceanengineFail;
    }
    HttpUtils.post(
      url,
      params,
      success: (data) {},
      fail: (code, msg) {},
    );
  }

  /// 保留接口，内部仍走统一通道
  static void douYinEvent({required String jsonParams}) {
    ChannelOperate.oceanengineEvent(jsonParams);
  }
}
