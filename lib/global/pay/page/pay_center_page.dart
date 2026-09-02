/*
 * @Author: duncy
 * @Date: 2025-10-13 13:57:23
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-26 11:20:46
 * @FilePath: /ling_bao/lib/global/pay/page/pay_center_page.dart
 * @Description: 
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/service/animate/scale_transition_widget.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/ui/view/video/byhy_video_player_view.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/launch/controller/launch_controller.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/pay/bean/pay_preview_media.dart';
import 'package:ling_bao/global/pay/bean/vip_type_bean.dart';
import 'package:ling_bao/global/pay/controller/pay_controller.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:video_player/video_player.dart';

class PayCenterPage extends StatefulWidget {
  const PayCenterPage({super.key});

  @override
  State<PayCenterPage> createState() => _PayCenterPageState();
}

class _PayCenterPageState extends State<PayCenterPage>
    with TickerProviderStateMixin {
  PayController get controller => Get.find<PayController>();
  bool switchValue = true;
  VideoPlayerController? _defaultPayVideoController;

  bool _isCurrentSubscribePackage() {
    if (controller.payType.value != PayType.vip) {
      return false;
    }
    final List<dynamic> packages = controller.getCurrentDataList();
    if (packages.isEmpty) {
      return false;
    }
    final int index = controller.payManager.selectIndex.value;
    if (index < 0 || index >= packages.length) {
      return false;
    }
    final dynamic item = packages[index];
    return item is VipTypeBean && (item.isSubscribe ?? 0) == 1;
  }

  @override
  void initState() {
    super.initState();
    _initDefaultPayVideo();
  }

  Future<void> _initDefaultPayVideo() async {
    final videoController = VideoPlayerController.asset(
      'assets/global/launch/pay.mp4',
    );
    await videoController.initialize();
    await videoController.setLooping(true);
    await videoController.setVolume(0);
    await videoController.play();
    if (!mounted) {
      videoController.dispose();
      return;
    }
    setState(() {
      _defaultPayVideoController = videoController;
    });
  }

  @override
  void dispose() {
    _defaultPayVideoController?.dispose();
    super.dispose();
  }

  Widget _buildPayMethodIcon(Map<String, dynamic> payMethod) {
    final String? icon = payMethod['icon'] as String?;
    if (icon != null && icon.isNotEmpty) {
      return Image.asset(icon, width: 20, height: 20);
    }
    final IconData? iconData = payMethod['iconData'] as IconData?;
    if (iconData != null) {
      return Icon(iconData, size: 20, color: ByColor.colorF1);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPayMethodItem({
    required Map<String, dynamic> payMethod,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _buildPayMethodIcon(payMethod),
            const SizedBox(width: 4),
            ByText.text(
              text: payMethod['payLabel'] ?? payMethod['payName'] ?? '',
              textColor: ByColor.colorF1,
            ),
            const SizedBox(width: 4),
            Image.asset(
              'assets/pay/radio_${isSelected ? 'selected' : 'unselected'}.png',
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ByColor.colorBg1,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 600.w,
            child: _buildTopBackground(),
          ),

          if (controller.previewPayload?.layout == PayPreviewLayout.videoList &&
              (controller.previewPayload?.items.length ?? 0) > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56.w,
              left: 0,
              right: 0,
              child: _buildVideoPreviewList(),
            ),

          Positioned(
            top: 400.w,
            left: 0,
            right: 0,
            child: Container(
              height: 200.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ByColor.colorBg1.withAlphaValue(0.0),
                    ByColor.colorBg1,
                  ],
                  begin: .topCenter,
                  end: .bottomCenter,
                ),
              ),
            ),
          ),

          ///付费页
          Positioned(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/pay/logo_flash_dream_ai.png',
                    height: 39.w,
                  ),
                  SizedBox(height: 10.w),
                  ByText.text(text: '舞动照片，释放你的创造力!', fontSize: 18.sp),
                  SizedBox(height: 10.w),
                  Obx(() {
                    ///开启会员免费试用
                    final itemList = controller.getCurrentDataList();
                    if (itemList.isEmpty) {
                      return SizedBox(
                        height: 300.w,
                        child: MultiStatusView(
                          currentStatus:
                              controller.payManager.payData.statusType.value,
                          action: () {
                            final LaunchController launch =
                                Get.find<LaunchController>();
                            if (!launch.isLaunched.value) {
                              launch.appLaunch(
                                onSuccess: (bean) {
                                  GlobalController.instance.init();
                                },
                              );
                            } else {
                              controller.payManager.payData.init();
                            }
                          },
                          loadingWidget: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ByColor.colorC1,
                              ),
                              strokeWidth: 1,
                            ),
                          ),
                          child: Container(),
                        ),
                      );
                    }
                    double height = 181.w;

                    ///横版
                    if (controller.styleManager.type == 1) {
                      height = 88.w * itemList.length;
                    }
                    return SizedBox(height: height, child: _buildPayList());
                  }),

                  /// 新人立减
                  _buildNewUserDiscount(),
                  _buildPayWay(),

                  ///底部支付按钮
                  SizedBox(
                    height: 48.w,
                    child: Obx(
                      () => controller.getCurrentDataList().isNotEmpty
                          ? ScaleTransitionWidget(
                              min: 0.95,
                              max: 1,
                              period: 900,
                              child: ByWidgetsUtil.gradientBtn(
                                title: controller.getPackageButtonText(),
                                fontSize: 16.sp,
                                fontWeight: .bold,
                                onClick: () {
                                  controller.sourcePosition = 4;
                                  controller.startPay(
                                    vipList:
                                        controller.getCurrentDataList()
                                            as List<VipTypeBean>,
                                  );
                                },
                              ),
                            )
                          : Container(),
                    ),
                  ),
                  SizedBox(height: 20.w),
                  Obx(
                    () => controller.getCurrentDataList().isEmpty
                        ? SizedBox(height: 20.w)
                        : AgreementView(
                            show: controller.user.isAudit(),
                            selected: controller.agreementChecked.value,
                            showMemberSubscribeAgreement:
                                _isCurrentSubscribePackage(),
                            tap: () {
                              controller.agreementCheckedChanged(
                                !controller.agreementChecked.value,
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 10.w + ByScreenUtils.bottomSafeHeight),
                ],
              ),
            ),
          ),
          closeView(),
        ],
      ),
    );
  }

  Widget _buildTopBackground() {
    final PayPreviewPayload? payload = controller.previewPayload;
    final PayPreviewMedia? media = payload?.firstItem;

    if (media != null && media.hasVideo) {
      return IgnorePointer(
        child: VideoPlayerWidget(
          key: ValueKey('pay-background-video-${media.videoUrl}'),
          url: media.videoUrl,
          coverUrl: media.coverUrl,
          coverFit: BoxFit.cover,
          videoFit: BoxFit.cover,
          autoPlay: true,
          mute: false,
          userInteractive: false,
          showVideoProgress: false,
        ),
      );
    }

    if (media != null && media.coverUrl.trim().isNotEmpty) {
      return CachedNetworkImage(imageUrl: media.coverUrl, fit: BoxFit.cover);
    }

    final String bgUrl = controller.bgUrl.trim();
    if (bgUrl.isEmpty) {
      return _buildDefaultPayVideo();
    }

    return CachedNetworkImage(imageUrl: bgUrl, fit: BoxFit.cover);
  }

  Widget _buildVideoPreviewList() {
    final List<PayPreviewMedia> items = controller.previewPayload?.items ?? [];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final double cardWidth = MediaQuery.of(context).size.width;
    final double listHeight = items
        .map((PayPreviewMedia item) => _previewCardHeight(item, cardWidth))
        .fold<double>(
          0,
          (double value, double item) => item > value ? item : value,
        );

    if (items.length == 1) {
      return SizedBox(
        height: listHeight,
        child: _buildPreviewCard(items.first, cardWidth),
      );
    }

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: 0.w),
        itemBuilder: (BuildContext context, int index) {
          return _buildPreviewCard(items[index], cardWidth);
        },
      ),
    );
  }

  Widget _buildPreviewCard(PayPreviewMedia media, double cardWidth) {
    final double cardHeight = _previewCardHeight(media, cardWidth);
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (media.hasVideo)
            IgnorePointer(
              child: VideoPlayerWidget(
                key: ValueKey('pay-preview-video-${media.videoUrl}'),
                url: media.videoUrl,
                coverUrl: media.coverUrl,
                coverFit: BoxFit.cover,
                videoFit: BoxFit.cover,
                autoPlay: true,
                mute: false,
                userInteractive: false,
                showVideoProgress: false,
              ),
            )
          else if (media.coverUrl.trim().isNotEmpty)
            CachedNetworkImage(imageUrl: media.coverUrl, fit: BoxFit.cover)
          else
            _buildDefaultPayVideo(),
        ],
      ),
    );
  }

  Widget _buildDefaultPayVideo() {
    final controller = _defaultPayVideoController;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  double _previewCardHeight(PayPreviewMedia media, double cardWidth) {
    final double ratio = media.aspectRatioValue;
    if (ratio <= 0) {
      return cardWidth / (4 / 3);
    }
    return cardWidth / ratio;
  }

  ///会员支付列表
  Widget _buildPayList() {
    return Obx(() {
      final dataList = controller.getCurrentDataList();
      if (controller.styleManager.type == 1) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(
              dataList.length,
              (index) => _buildPayItem(index, 'vip'),
            ),
          ),
        );
      }
      final bean = dataList[controller.payManager.selectIndex.value];
      return Column(
        children: [
          SizedBox(
            height: 150.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dataList.length,
              separatorBuilder: (context, index) {
                return SizedBox(width: 8.w);
              },
              itemBuilder: (context, index) {
                return _buildPayItem(index, 'vip');
              },
            ),
          ),

          ByText.text(
            text: '${bean.des}',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            textColor: ByColor.colorF1.withAlphaValue(0.32),
          ),
        ],
      );
    });
  }

  ///会员支付列表
  Widget _buildPayItem(int index, String payType) {
    final dataList = controller.getCurrentDataList();
    final vipTypeBean = dataList[index];
    double width = dataList.length <= 2 ? 167.w : 111.w;
    return GestureDetector(
      onTap: () {
        controller.switchVipListCurrent(index);
      },
      child: Obx(() {
        final isSelected = controller.payManager.selectIndex.value == index;
        return Padding(
          padding: EdgeInsets.only(
            bottom: 12.w,
            top: controller.styleManager.type == 1 ? 0 : 12.w,
          ),
          child: Container(
            width: controller.styleManager.type == 1 ? double.infinity : width,
            height: controller.styleManager.type == 1 ? 76.w : 132.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: controller.styleManager.type == 1 || !isSelected
                  ? null
                  : LinearGradient(
                      begin: AlignmentGeometry.bottomRight,
                      end: AlignmentGeometry.topLeft,
                      colors: [Color(0xFF12070F), Color(0xFF34101C)],
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlphaValue(0.04), // 阴影颜色（带透明度）
                  spreadRadius: 5, // 阴影扩散半径
                  blurRadius: 6, // 阴影模糊半径
                  offset: const Offset(0, 2), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
                ),
              ],
              border: Border.all(
                color: controller.styleManager.type == 1
                    ? isSelected
                          ? ByColor.colorC1
                          : Colors.transparent
                    : isSelected
                    ? ByColor.colorC1
                    : ByColor.colorF0.withAlphaValue(0.1),
                width: 2,
              ),
              color: ByColor.colorBg2,
            ),
            child: Stack(
              children: [
                ///横版
                controller.styleManager.type == 1 ||
                        controller.payType.value == PayType.token
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: 9.w,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/global/common/btn_checkbox_${isSelected ? "selected" : "normal"}.png',
                                width: 16.w,
                                height: 16.w,
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///标题位
                                  ByText.text(
                                    text: vipTypeBean.title,
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.bold,
                                    textColor: ByColor.colorF1,
                                  ),
                                  SizedBox(
                                    width: 280.w,
                                    child: ByText.text(
                                      text:
                                          '${controller.getPrice(vipTypeBean)} ${vipTypeBean.des}',
                                      fontSize: 13.sp,
                                      textColor: ByColor.colorF2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    :
                      ///竖版
                      Positioned(
                        top: 0,
                        left: 10,
                        right: 10,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: .start,
                          children: [
                            ///标题位
                            ByText.text(
                              // text: vipTypeBean.title,
                              text: controller.styleManager.getPayTypeName(
                                vipTypeBean,
                                1,
                              ),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              textColor: ByColor.colorF0,
                            ),
                            SizedBox(height: 3.w),
                            ByText.text(
                              text: controller.styleManager.getPayTypeName(
                                vipTypeBean,
                                2,
                              ),
                              fontSize: 12.sp,
                              textColor: Color(0x8CFFFFFF),
                            ),
                            SizedBox(height: 15.w),
                            SizedBox(
                              height: 17.w,
                              child: Obx(
                                () =>
                                    (controller.showNewUserDiscountView() ||
                                        controller
                                            .payManager
                                            .payData
                                            .vipDiscountList
                                            .isEmpty ||
                                        index != 1)
                                    ? ByText.text(
                                        // text: vipTypeBean.title,
                                        text: '￥${vipTypeBean.crossedMoney}',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        textColor: Color(0x8CFFFFFF),
                                        decoration: .lineThrough,
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ),
                            if (controller.payType.value == PayType.vip)
                              ByWidgetsUtil.commonRichText(
                                texts: [
                                  TextSpan(
                                    text: controller.styleManager
                                        .getPayTypeName(vipTypeBean, 3),
                                  ),
                                  TextSpan(
                                    text: controller.styleManager
                                        .getPayTypeName(vipTypeBean, 4),
                                    style: TextStyle(
                                      fontSize: 25.sp,
                                      color: ByColor.colorF0,
                                    ),
                                  ),
                                  TextSpan(
                                    // text: '/day'
                                    text: controller.styleManager
                                        .getPayTypeName(vipTypeBean, 5),
                                  ),
                                ],
                                textColor: ByColor.colorF1,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                          ],
                        ),
                      ),
                if (vipTypeBean.isDefault == 1 &&
                    (vipTypeBean.mark?.toString().trim().isNotEmpty ?? false))
                  _builditemLabel(vipTypeBean),
              ],
            ),
          ),
        );
      }),
    );
  }

  ///列表 label
  Widget _builditemLabel(dynamic vipTypeBean) {
    String deMarkString = "";

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        height: 24,
        transform: Matrix4.identity()..translateByDouble(0, -12, 0, 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: ByColor.colorG1(),
        ),
        alignment: Alignment.center,
        child: ByText.text(
          text: vipTypeBean.mark.isNotEmpty ? vipTypeBean.mark : deMarkString,
          fontSize: 10.sp,
          textColor: ByColor.colorF0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 新用户折扣
  Widget _buildNewUserDiscount() {
    if (!controller.showNewUserDiscountView()) {
      return SizedBox.shrink();
    }
    return Obx(
      () => controller.payManager.selectIndex.value == 1
          ? Container(
              height: 50.w,
              margin: EdgeInsets.only(bottom: 10.w),
              padding: EdgeInsets.only(left: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                gradient: LinearGradient(
                  colors: [Color(0xFFFEFADF), Color(0xFFFECA70)],
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/pay/icon_pay_discount_tip.png',
                    width: 36.w,
                    height: 38.w,
                  ),
                  SizedBox(width: 4.w),
                  ByText.text(
                    text: '新人立减特权',
                    textColor: Color(0xFFAA5B16),
                    fontSize: 16.sp,
                    fontWeight: .w500,
                  ),
                  const Spacer(),
                  ByText.text(
                    text: '-￥800',
                    textColor: ByColor.colorC1,
                    fontSize: 19.sp,
                    fontWeight: .w700,
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      controller.newUserDiscount.value =
                          !controller.newUserDiscount.value;
                      final List<VipTypeBean> list =
                          controller.getCurrentDataList() as List<VipTypeBean>;
                      controller.payManager.refreshVipPayMethods(
                        bean: list[1],
                        vipList: list,
                      );
                    },
                    child: Container(
                      width: 32.w,
                      height: 50.w,
                      padding: EdgeInsets.only(
                        left: 4.w,
                        right: 12.w,
                        top: 17.w,
                        bottom: 17.w,
                      ),
                      child: Obx(
                        () => Image.asset(
                          'assets/pay/radio_${controller.newUserDiscount.value ? 'selected' : 'unselected'}.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }

  ///支付方式
  Widget _buildPayWay() {
    return Obx(() {
      if (controller.newUserDiscount.value) {}
      final isVipList = controller.payType.value == .vip;
      if (isVipList) {
        controller.payManager.payData.vipList.length;
        controller.payManager.selectIndex.value;
      }
      final payList = isVipList
          ? controller.payManager.payMethodBeans
          : controller.payManager.wordPackagePayMethodBeans;
      final payIndex = isVipList
          ? controller.payManager.currentPayMethodIndex.value
          : controller.payManager.currentWordPackagePayMethodIndex.value;
      print("___payIndex:$payIndex,__payList:$payList");
      if (payList.isEmpty) {
        return const SizedBox.shrink();
      }

      if (payIndex >= payList.length) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 38.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ByText.text(text: '支付方式', textColor: ByColor.colorF0),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(payList.length, (index) {
                        final Map<String, dynamic> payMethod = payList[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == payList.length - 1 ? 0 : 8,
                          ),
                          child: _buildPayMethodItem(
                            payMethod: payMethod,
                            isSelected: payIndex == index,
                            onTap: () {
                              if (payIndex == index) {
                                return;
                              }
                              controller.payManager.switchPayMethod(index);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  ///关闭按钮
  Widget closeView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      child: GestureDetector(
        onTap: () {
          controller.closePayPage();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32.w,
          height: 32.w,
          margin: EdgeInsets.only(left: 12, top: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.w),
            color: ByColor.colorBg1.withAlphaValue(0.4),
          ),
          alignment: Alignment.center,
          child: Image.asset(
            "assets/global/common/btn_close.png",
            width: 32.w,
            height: 32.w,
          ),
        ),
      ),
    );
  }
}

class AgreementView extends StatelessWidget {
  const AgreementView({
    super.key,
    this.style = 0,
    this.selected = false,
    this.show = true,
    this.showMemberSubscribeAgreement = false,
    this.tap,
  });

  /// 类型0为浅色，1为深色
  final int? style;
  final bool selected;
  final bool show;
  final bool showMemberSubscribeAgreement;
  final Function? tap;

  @override
  Widget build(BuildContext context) {
    return _buildAgreement();
  }

  /// 协议
  Widget _buildAgreement() {
    return GestureDetector(
      onTap: () => tap?.call(),
      child: SizedBox(
        height: 20.w,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (show)
                Padding(
                  padding: EdgeInsets.only(top: 2.w),
                  child: Image.asset(
                    selected
                        ? "assets/pay/radio_selected.png"
                        : "assets/pay/radio_unselected.png",
                    fit: .fill,
                    width: 16.w,
                    height: 16.w,
                  ),
                ),
              SizedBox(width: 4),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    RichText(
                      maxLines: 2,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '已同意',
                            style: TextStyle(
                              fontSize: 12,
                              color: ByColor.colorF2,
                            ),
                          ),
                          // TextSpan(
                          //   text: "隐私政策",
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: style == 1
                          //         ? ByColor.colorF2
                          //         : ByColor.colorF1,
                          //     decoration: TextDecoration.underline,
                          //   ),
                          //   recognizer: TapGestureRecognizer()
                          //     ..onTap = () {
                          //       GlobalController.instance.config
                          //           .goPrivacyPageWithTitle("隐私政策");
                          //     },
                          // ),
                          // const TextSpan(
                          //   text: '和',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: ByColor.colorF2,
                          //   ),
                          // ),
                          // TextSpan(
                          //   text: "用户协议",
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: style == 1
                          //         ? ByColor.colorF2
                          //         : ByColor.colorF1,
                          //     decoration: TextDecoration.underline,
                          //   ),
                          //   recognizer: TapGestureRecognizer()
                          //     ..onTap = () {
                          //       GlobalController.instance.config
                          //           .goPrivacyPageWithTitle("用户协议");
                          //     },
                          // ),
                          // const TextSpan(
                          //   text: '和',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: ByColor.colorF2,
                          //   ),
                          // ),
                          TextSpan(
                            text: "会员服务协议",
                            style: TextStyle(
                              fontSize: 12,
                              color: style == 1
                                  ? ByColor.colorF2
                                  : ByColor.colorF1,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                GlobalController.instance.config
                                    .goPrivacyPageWithTitle("会员服务协议");
                              },
                          ),
                          if (showMemberSubscribeAgreement)
                            const TextSpan(
                              text: "和",
                              style: TextStyle(
                                fontSize: 12,
                                color: ByColor.colorF2,
                              ),
                            ),
                          if (showMemberSubscribeAgreement)
                            TextSpan(
                              text: "会员订阅协议",
                              style: TextStyle(
                                fontSize: 12,
                                color: style == 1
                                    ? ByColor.colorF2
                                    : ByColor.colorF1,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  GlobalController.instance.config
                                      .goPrivacyPageWithTitle("会员订阅协议");
                                },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
