/*
 * @Author: duncy
 * @Date: 2026-03-24 14:19:31
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-13 18:18:51
 * @FilePath: /ling_bao/lib/global/other/event_tracking/event_tracking.dart
 * @Description: 
 */
import 'dart:convert';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/global/launch/controller/launch_controller.dart';

import '../../../core/util/by_device_info_utils.dart';

class EventTracking {
  ///新数据埋点上报
  ///
  ///undertake_type 承接模式：1：审核面上报 2：老的承接 3：短剧授权承接弹框 4：0粉丝变现承接页 0：无承接
  static Future<void> reportDataPoint({
    required String pageTag,
    required String operateType,
    required String funcDetailTag,
    required String funcDetailImg,
    String undertakeType = "0",
    int retry = 0,
    Map<String, dynamic>? extra,
  }) async {
    final String network = await ByDeviceInfoUtils.getNetworkStatus();
    final int isAudit = Get.find<LaunchController>().launchInfo?.isAudit ?? 0;

    print('_______页面上报:::::$pageTag,$operateType');

    // 处理 extra 参数，过滤掉数组，然后转换为 JSON 字符串
    Map<String, dynamic> extraData = {};
    if (extra != null) {
      extra.forEach((key, value) {
        // 只保留非数组类型的值（字符串、数字、布尔值、null、嵌套对象）
        if (value is! List) {
          if (value is Map) {
            // 递归处理嵌套的 Map，确保也不包含数组
            extraData[key] = _filterExtraData(value);
          } else {
            extraData[key] = value;
          }
        }
        // 如果是数组，则跳过，不添加到 extraData 中
      });
    }
    // 将 extra 转换为 JSON 字符串
    String extraJson = jsonEncode(extraData);

    HttpUtils.post(
      APIs.eventReport,
      {
        "event": "behavior",
        "page_tag": pageTag, //页面标识 event=behavior必填
        "operate_type": operateType, //操作类型 view/click  event=behavior必填
        "func_detail_tag": funcDetailTag.isEmpty
            ? 0
            : (int.tryParse(funcDetailTag) ??
                  0), // 对应功能的明细ID  eevent=behavior 需要，确保为数字类型
        // 比如: 如果是
        //  功能区, 则对应功能区的标识
        //  视频广场分类点击=>分类ID
        //  视频广场列表=>视频ID
        //  推广类型tab点击=>类型ID
        //  登录页=>登录类型(1:一键登录/手机号登录/微信登录)
        // 支付页=>支付页标识
        "func_detail_img": funcDetailImg.isEmpty
            ? ""
            : funcDetailImg, //event=behavior 需要  点击的对应功能图片(如果有的话)
        "extra": extraJson, //额外参数 JSON字符串格式，已过滤掉数组
        "network": network, //网络类型 2G/3G/4G/WIFI
        // "undertake_type": undertakeType, //承接模式
        "is_audit": isAudit, //是否是审核面
      },
      showMsgWhenFailed: false, // 埋点上报失败时不显示错误提示，静默处理
      success: (data) {},
      fail: (code, msg) {
        if (retry == 0) {
          reportDataPoint(
            pageTag: pageTag,
            operateType: operateType,
            funcDetailTag: funcDetailTag,
            funcDetailImg: funcDetailImg,
            extra: extra,
            undertakeType: undertakeType,
            retry: 1,
          );
        }
      },
    );
  }

  /// 递归过滤 extra 数据，确保只包含 JSON 对象能接受的值（不包含数组）
  static Map<String, dynamic> _filterExtraData(Map<dynamic, dynamic> data) {
    Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (value is! List) {
        if (value is Map) {
          result[key.toString()] = _filterExtraData(value);
        } else {
          result[key.toString()] = value;
        }
      }
      // 如果是数组，则跳过
    });
    return result;
  }
}
