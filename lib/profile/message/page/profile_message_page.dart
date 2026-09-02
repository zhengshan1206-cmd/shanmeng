import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/page/base_page.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:ling_bao/profile/message/bean/message_list_bean.dart';
import 'package:ling_bao/profile/message/controller/message_controller.dart';

// ignore: must_be_immutable
class ProfileMessagePage extends BasePage {
  ProfileMessagePage({super.key}) {
    title = '消息通知';
  }

  @override
  final MessageController controller = Get.find<MessageController>();

  Widget _buildMessageCell(MessageListBean bean) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.jumpMessageDetails(bean),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF232428),
          borderRadius: BorderRadius.circular(14.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bean.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  bean.notifyDate,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.34),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    bean.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (bean.isRead == 0) ...[
                  SizedBox(width: 8.w),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: ByColor.colorC1,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Obx(
      () => MultiStatusView(
        currentStatus: controller.statusType.value,
        emptyText: '空空如也~',
        action: () => controller.getMessageList(true),
        child: ByRefresh.refresh(
          controller: controller.refreshManager.refreshController,
          enablePullUp:
              controller.hasMore.value && controller.messageList.isNotEmpty,
          onRefresh: () => controller.getMessageList(true),
          onLoad: () => controller.getMessageList(false),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 20.h),
            itemCount: controller.messageList.length,
            itemBuilder: (_, index) =>
                _buildMessageCell(controller.messageList[index]),
          ),
        ),
      ),
    );
  }
}
