import 'package:get/get.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/profile/order/bean/subscription_order_bean.dart';

class OrderManagementController extends GetxController {
  static const int _pageSize = 10;

  final RxList<SubscriptionOrderBean> orders = <SubscriptionOrderBean>[].obs;

  final RefreshManager refreshManager = RefreshManager();

  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderList(true);
  }

  SubscriptionOrderBean? get currentOrder {
    for (final item in orders) {
      if (item.status != 1 && item.status != 3) {
        return item;
      }
    }
    return null;
  }

  bool get canCancelCurrentOrder => currentOrder != null;

  void refreshOrders() {
    fetchOrderList(true);
  }

  void loadMore() {
    fetchOrderList(false);
  }

  void fetchOrderList(bool isRefresh) {
    final manager = refreshManager;
    if (!manager.beginRequest(isRefresh, hasMore: hasMore.value)) {
      return;
    }
    if (isRefresh) {
      hasMore.value = true;
    }
    final int requestPage = manager.pageHelper.page;
    HttpUtils.get(
      APIs.orderSubscribeList,
      {'page': requestPage, 'limit': _pageSize, 'is_subscribing': 1},
      success: (data) {
        final dynamic resData = data['data'];
        final List list = resData is Map ? (resData['data'] ?? []) : [];
        final int lastPage = resData is Map
            ? (resData['last_page'] as int? ?? 1)
            : 1;
        final beans = list
            .map(
              (e) => SubscriptionOrderBean.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        if (isRefresh) {
          orders.value = beans;
        } else {
          orders.addAll(beans);
        }
        final bool nextHasMore = requestPage < lastPage;
        hasMore.value = nextHasMore;
        manager.completeSuccess(isRefresh: isRefresh, hasMore: nextHasMore);
      },
      fail: (code, msg) {
        manager.completeFailed(isRefresh);
        Toast.showText(text: msg);
      },
    );
  }

  void applyCancelSubscribe(SubscriptionOrderBean item) {
    HttpUtils.post(
      APIs.cancelSubscription,
      {'order_no': item.subscribeOrderNo},
      success: (data) {
        refreshOrders();
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
      },
    );
  }

  @override
  void onClose() {
    refreshManager.dispose();
    super.onClose();
  }
}
