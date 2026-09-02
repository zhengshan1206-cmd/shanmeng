import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/dialog/diolog_view.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/global/routes/app_pages.dart';
import 'package:ling_bao/profile/order/page/profile_order_shared.dart';
import 'package:ling_bao/profile/order/bean/subscription_order_bean.dart';
import 'package:ling_bao/profile/order/controller/order_management_controller.dart';

class ProfileOrderManagementPage extends StatelessWidget {
  ProfileOrderManagementPage({super.key});

  final OrderManagementController controller =
      Get.find<OrderManagementController>();

  String _periodText(SubscriptionOrderBean item) {
    // if (item.status == 1) {
    //   return '预订阅';
    // }
    // if (item.status == 3) {
    //   return '已取消';
    // }
    return '订阅金额';
  }

  String _priceText(SubscriptionOrderBean item) {
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

  Widget _buildSubscriptionCard(SubscriptionOrderBean item) {
    return ProfileSubscriptionOrderCard(
      title: item.title,
      periodText: _periodText(item),
      priceText: _priceText(item),
      signTime: item.signTime,
      executeText: _executeText(item),
    );
  }

  Widget _buildListView() {
    return Obx(() {
      final bool empty = controller.orders.isEmpty;

      return MultiStatusView(
        currentStatus: empty
            ? MultiStatusType.statusEmpty
            : MultiStatusType.statusContent,
        emptyText: '暂无订阅记录',
        backgroundColor: Colors.transparent,
        hasAppBar: false,
        child: ByRefresh.refresh(
          controller: controller.refreshManager.refreshController,
          enablePullDown: true,
          enablePullUp:
              controller.hasMore.value && controller.orders.isNotEmpty,
          onRefresh: controller.refreshOrders,
          onLoad: controller.loadMore,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 108.h),
            itemCount: controller.orders.length,
            itemBuilder: (_, index) =>
                _buildSubscriptionCard(controller.orders[index]),
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar() {
    return Obx(() {
      if (controller.orders.isEmpty) {
        return const SizedBox.shrink();
      }

      final SubscriptionOrderBean? currentOrder = controller.currentOrder;

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
          child: ProfileOrderOutlineButton(
            label: '取消订阅',
            enabled: controller.canCancelCurrentOrder,
            onTap: currentOrder == null
                ? null
                : () {
                    Get.dialog(
                      NovelDialog(
                        title: '申请取消订阅',
                        content: '取消后会员到期将失去会员特权，仍可手动续费恢复。',
                        onConfirm: () {
                          controller.applyCancelSubscribe(currentOrder);
                        },
                      ),
                    );
                  },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileOrderPageScaffold(
      title: '订阅管理',
      actionText: '历史订单',
      onActionTap: () {
        Get.toNamed(Routes.orderHistory);
      },
      bottomBar: _buildBottomBar(),
      child: _buildListView(),
    );
  }
}
