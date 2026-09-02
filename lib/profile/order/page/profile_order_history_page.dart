import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/profile/order/page/profile_order_shared.dart';
import 'package:ling_bao/profile/order/bean/subscription_order_bean.dart';
import 'package:ling_bao/profile/order/controller/order_history_controller.dart';

class ProfileOrderHistoryPage extends StatelessWidget {
  ProfileOrderHistoryPage({super.key});

  final OrderHistoryController controller = Get.find<OrderHistoryController>();

  String _periodText(SubscriptionOrderBean item) {
    // if (item.status == 1) {
    //   return '预订阅';
    // }
    // if (item.status == 3) {
    //   return '已取消';
    // }
    return '订阅金额';
  }

  String _amountText(SubscriptionOrderBean item) {
    if (item.subscribeMoneyValue <= 0) {
      return '--';
    }
    return '¥${item.subscribeMoney}';
  }

  String _executeText(SubscriptionOrderBean item) {
    if (item.executeTime.isNotEmpty) {
      return item.executeTime;
    }
    if (item.cyclePayTime.isNotEmpty) {
      return item.cyclePayTime;
    }
    if (item.status == 3) {
      return item.cancelTime.isNotEmpty ? item.cancelTime : '已取消';
    }
    return '未扣费';
  }

  Widget _buildOrderCard(SubscriptionOrderBean item) {
    return ProfileSubscriptionOrderCard(
      title: item.title,
      periodText: _periodText(item),
      priceText: _amountText(item),
      signTime: item.signTime,
      executeText: _executeText(item),
    );
  }

  Widget _buildListView() {
    return Obx(() {
      final bool empty = controller.historyOrders.isEmpty;

      return MultiStatusView(
        currentStatus: empty
            ? MultiStatusType.statusEmpty
            : MultiStatusType.statusContent,
        emptyText: '暂无历史订单',
        backgroundColor: Colors.transparent,
        hasAppBar: false,
        child: ByRefresh.refresh(
          controller: controller.refreshManager.refreshController,
          enablePullDown: true,
          enablePullUp:
              controller.hasMore.value && controller.historyOrders.isNotEmpty,
          onRefresh: controller.refreshOrders,
          onLoad: controller.loadMore,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 24.h),
            itemCount: controller.historyOrders.length,
            itemBuilder: (_, index) =>
                _buildOrderCard(controller.historyOrders[index]),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileOrderPageScaffold(title: '历史订单', child: _buildListView());
  }
}
