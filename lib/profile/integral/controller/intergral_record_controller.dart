/*
 * @Author: duncy
 * @Date: 2026-04-13 13:48:00
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 14:29:28
 * @FilePath: /ling_bao/lib/profile/integral/controller/intergral_record_controller.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:ling_bao/global/user/user.dart';

import '../../../core/network/http_utils.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/ui/dialog/toast.dart';
import '../../../core/ui/view/muti_status_view.dart';
import '../../../core/ui/widget/by_refresh.dart';
import '../bean/intergral_record_bean.dart';

class IntergralRecordController extends GetxController {
  final RefreshManager refreshManager = RefreshManager();

  Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;

  RxList<IntergralRecordBean> dataList = <IntergralRecordBean>[].obs;
  RxBool hasMore = true.obs;

  final UserController user = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    fetchCreditsItemList(true);
  }

  ///拉取积分商品列表
  void fetchCreditsItemList(
    bool isRefresh, {
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
  }) {
    final manager = refreshManager;
    if (!manager.beginRequest(isRefresh, hasMore: hasMore.value)) {
      return;
    }
    if (isRefresh) {
      if (dataList.isEmpty) {
        statusType.value = MultiStatusType.statusLoading;
      }
      hasMore.value = true;
    }
    HttpUtils.get(
      NovelApis.getIntegralConsumeList,
      {
        'size': manager.pageHelper.row, // 每页数量
        'page': manager.pageHelper.page, // 页数
        'type': 0,
      },
      showMsgWhenFailed: false,
      success: (data) {
        //处理数据
        statusType.value = MultiStatusType.statusContent;
        final List<dynamic> list = data['data']['items'] ?? [];
        final List<IntergralRecordBean> beans = list
            .map((e) => IntergralRecordBean.fromJson(e))
            .toList();
        if (isRefresh) {
          dataList.value = beans; // 刷新时清空列表
        } else {
          dataList.addAll(beans); // 加载更多时追加数据
        }
        if (dataList.isEmpty) {
          statusType.value = MultiStatusType.statusEmpty;
        } else {
          statusType.value = MultiStatusType.statusContent;
        }
        final bool nextHasMore = beans.length >= manager.pageHelper.row;
        hasMore.value = nextHasMore;
        manager.completeSuccess(isRefresh: isRefresh, hasMore: nextHasMore);
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        if (dataList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        manager.completeFailed(isRefresh);
        Toast.showText(text: msg);
        onFail?.call(code, msg);
      },
    );
  }

  @override
  void onClose() {
    refreshManager.dispose();
    super.onClose();
  }
}
