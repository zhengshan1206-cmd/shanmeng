import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/page/base_page.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:ling_bao/profile/message/bean/message_list_bean.dart';

// ignore: must_be_immutable
class MessageDetailsPage extends BasePage {
  MessageDetailsPage({super.key}) {
    title = '消息详情';
  }

  MessageListBean? get _message => Get.arguments is MessageListBean
      ? Get.arguments as MessageListBean
      : null;

  @override
  Widget buildBody(BuildContext context) {
    final message = _message;
    if (message == null) {
      return Center(
        child: Text(
          '暂无消息内容',
          style: TextStyle(color: ByColor.colorF2, fontSize: 14.sp),
        ),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(12.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Color(0xFF232323),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.title,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 12.h),
            Text(
              message.content,
              style: TextStyle(
                color: Color(0xFFA0A0A7),
                fontSize: 15.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message.notifyDate,
              style: TextStyle(
                color: Color(0xFFFFFFFF).withValues(alpha: 0.35),
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
