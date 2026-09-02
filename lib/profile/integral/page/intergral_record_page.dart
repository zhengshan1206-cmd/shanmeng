import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:ling_bao/core/util/extentions.dart';

import '../../../core/ui/page/base_page.dart';
import '../../../core/ui/view/muti_status_view.dart';
import '../../../core/ui/widget/by_refresh.dart';
import '../../../core/ui/widget/by_text.dart';
import '../../../global/ui/colors.dart';
import '../controller/intergral_record_controller.dart';

// ignore: must_be_immutable
class IntergralRecordPage extends BasePage {
  IntergralRecordPage({super.key});

  @override
  String get title => '积分明细';

  @override
  IntergralRecordController get controller =>
      Get.find<IntergralRecordController>();

  final Color mainColor = Color(0xFFC6A7FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      extendBodyBehindAppBar: true,
      appBar: hasAppBar ? buildAppBar(context, isTransparent: true) : null,
      body: buildBody(context),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        color: ByColor.colorBg2,
        image: DecorationImage(
          alignment: .topCenter,
          image: AssetImage('assets/profile/icon_intergral_bg.png'),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Obx(
              () => Container(
                margin: EdgeInsets.only(left: 20.w),
                child: ByText.text(
                  text:
                      '${controller.user.userInfoBean.value?.integral ?? '0'}',
                  fontSize: 52.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.w),
              child: ByText.text(
                text: '剩余灵感值',
                fontSize: 17.sp,
                textColor: mainColor.withAlphaValue(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.w),
            Expanded(
              child: Obx(
                () => MultiStatusView(
                  emptyActionType: EmptyActionType.all,
                  emptyText: '暂无数据',
                  currentStatus: controller.statusType.value,
                  action: () {
                    controller.fetchCreditsItemList(true);
                  },
                  child: ByRefresh.refresh(
                    controller: controller.refreshManager.refreshController,
                    enablePullUp:
                        controller.hasMore.value &&
                        controller.dataList.isNotEmpty,
                    onRefresh: () {
                      controller.fetchCreditsItemList(true);
                    },
                    onLoad: () {
                      controller.fetchCreditsItemList(false);
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 8.w),
                      itemBuilder: (context, index) {
                        final item = controller.dataList[index];
                        return Container(
                          height: 82.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.w),
                            border: Border.all(
                              color: mainColor.withAlphaValue(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ByText.text(
                                    text: item.itemDesc ?? '',
                                    fontSize: 18.sp,
                                    textColor: mainColor,
                                  ),
                                  SizedBox(height: 8.h),
                                  ByText.text(
                                    text: item.createAt ?? '',
                                    fontSize: 13.sp,
                                    textColor: mainColor.withAlphaValue(0.5),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: .end,
                                children: [
                                  ByText.text(
                                    text: item.intergral! > 0
                                        ? '+${item.intergral}'
                                        : '${item.intergral}',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(height: 8.h),
                                  ByText.text(
                                    text: '剩余：${item.userIntergral}',
                                    textColor: mainColor.withAlphaValue(0.5),
                                    fontSize: 13.sp,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: controller.dataList.length,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.user.jumpToPayPage();
              },
              child: Container(
                height: 48.w,
                alignment: .center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/profile/btn_intergral_charge.png',
                    ),
                  ),
                ),
                child: ByText.text(
                  text: '立即充值',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: ByScreenUtils.bottomSafeHeight + 16.w),
          ],
        ),
      ),
    );
  }
}
