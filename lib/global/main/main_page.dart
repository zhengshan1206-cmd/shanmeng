/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:45:37
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-15 10:08:12
 * @FilePath: /ling_bao/lib/global/main/main_page.dart
 * @Description: 
 */

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/create/home_create_page.dart';
import 'package:ling_bao/global/main/main_controller.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:ling_bao/video/main/page/home_video_page.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../../image/home_image_tab.dart';
import '../ui/assets.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainController controller = Get.put(MainController(), permanent: true);

  @override
  void initState() {
    super.initState();
  }

  BottomBarItem tabbarItem({
    String? label,
    String? assets,
    String? selectedAssets,
    double iconWidth = 24,
    double iconHeight = 24,
  }) {
    return BottomBarItem(
      selectedColor: ByColor.colorF1,
      unSelectedColor: ByColor.colorF1.withAlphaValue(0.5),
      title: (label == null || label.isEmpty)
          ? const SizedBox.shrink()
          : Text(label, style: TextStyle(fontSize: 10.sp)),
      icon: assets == null
          ? const SizedBox()
          : Image.asset(assets, width: iconWidth, height: iconHeight),
      selectedIcon: Image.asset(
        selectedAssets!,
        width: iconWidth,
        height: iconHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyView(context);
  }

  Widget _bodyView(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: ByColor.colorBg1,
          bottomNavigationBar: Obx(
            () => StylishBottomBar(
              items: [
                tabbarItem(
                  label: 'Ai视频',
                  assets: Assets.tabVideo,
                  selectedAssets: Assets.tabVideoSelected,
                ),
                tabbarItem(
                  label: '',
                  assets: Assets.tabCreate,
                  selectedAssets: Assets.tabCreateSelected,
                  iconWidth: 46,
                  iconHeight: 46,
                ),
                tabbarItem(
                  label: 'Ai图片',
                  assets: Assets.tabImage,
                  selectedAssets: Assets.tabImageSelected,
                ),
              ],

              // option: DotBarOptions(
              //   // inkEffect: true
              //   gradient: LinearGradient(
              //     colors: [AppTheme.primaryColor, AppTheme.primaryColor],
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //   ),
              // ),
              option: AnimatedBarOptions(
                barAnimation: BarAnimation.fade,
                iconStyle: IconStyle.Default,
              ),
              hasNotch: true,
              currentIndex: controller.currentIndex.value,
              backgroundColor: ByColor.colorBg1,
              onTap: (index) {
                controller.tabChanged(index);
              },
            ),
          ),
          body: Obx(
            () => MultiStatusView(
              hasAppBar: false,
              currentStatus: controller.launchStatus.value,
              action: () {
                controller.fetchLaunchData();
              },
              child: IndexedStack(
                index: controller.currentIndex.value,
                children: <Widget>[
                  VideoTabPage(
                    isActive: controller.currentIndex.value == 0,
                    onOpenPayment: () => controller.openPayWall(),
                    onOpenProfile: () => controller.openProfile(),
                    onOpenSupport: () => controller.openSupportl(),
                    statusMessage: null,
                  ),
                  CreateTabPage(
                    onOpenPayment: () => controller.openPayWall(),
                    onOpenProfile: () => controller.openProfile(),
                    onOpenSupport: () => controller.openSupportl(),
                  ),
                  ImageTabPage(
                    isActive: controller.currentIndex.value == 2,
                    onOpenPayment: () => controller.openPayWall(),
                    onOpenProfile: () => controller.openProfile(),
                    onOpenSupport: () => controller.openSupportl(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
