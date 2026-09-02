/*
 * @Author: duncy
 * @Date: 2025-10-14 18:43:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-28 09:38:25
 * @FilePath: /ling_bao/lib/global/launch/page/guide_step_page.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:ling_bao/global/launch/controller/guide_step_controller.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:video_player/video_player.dart';
import '../../routes/app_pages.dart';
import '../controller/launch_manager.dart';

class GuideStepPage extends StatefulWidget {
  GuideStepPage({super.key});

  @override
  State<GuideStepPage> createState() => _GuideStepPageState();
}

class _GuideStepPageState extends State<GuideStepPage> {
  final GuideStepController controller = Get.put(GuideStepController());

  final List<String> titles = ["照片一键换装", "照片跳舞", "AI写真"];

  final List<String> subTitles = [
    "输入提示词，生成图片和视频",
    "上传全身照片，生成同款热门舞蹈视频",
    "海量热门写真场景&热门视频模板",
  ];

  final List<String> videoPaths = const [
    'assets/global/launch/outfit-change.mp4',
    'assets/global/launch/dance.mp4',
    'assets/global/launch/artistic-photo.mp4',
  ];

  final List<VideoPlayerController> videoControllers = [];

  @override
  void initState() {
    super.initState();
    _initVideoControllers();
  }

  @override
  void dispose() {
    for (final videoController in videoControllers) {
      videoController.dispose();
    }
    controller.pageController.dispose();
    super.dispose();
  }

  Future<void> _initVideoControllers() async {
    for (final path in videoPaths) {
      final videoController = VideoPlayerController.asset(path);
      await videoController.initialize();
      await videoController.setLooping(true);
      await videoController.setVolume(0);
      videoControllers.add(videoController);
    }
    if (!mounted) return;
    setState(() {});
    _playCurrentPageVideo(controller.currentIndex.value);
  }

  void _playCurrentPageVideo(int pageIndex) {
    for (int i = 0; i < videoControllers.length; i++) {
      if (i == pageIndex) {
        videoControllers[i].play();
      } else {
        videoControllers[i].pause();
      }
    }
  }

  void _releaseVideoResources() {
    for (final videoController in videoControllers) {
      videoController.pause();
      videoController.dispose();
    }
    videoControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            itemCount: titles.length,
            onPageChanged: (value) {
              controller.currentIndex.value = value;
              _playCurrentPageVideo(value);
            },
            itemBuilder: (context, index) {
              return _buildPage(context, index);
            },
          ),
          Positioned(
            bottom: 115.w + ByScreenUtils.bottomSafeHeight,
            child: Container(
              height: 5.w,
              width: 375.w,
              alignment: .center,
              child: Row(
                mainAxisAlignment: .center,
                children: List.generate(3, (index) {
                  return Obx(
                    () => Container(
                      width: controller.currentIndex.value == index
                          ? 24.w
                          : 12.w,
                      height: 5.w,
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5.w),
                        color: controller.currentIndex.value == index
                            ? ByColor.colorF0
                            : ByColor.colorF2,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///页码内容
  Widget _buildPage(BuildContext context, int index) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 51.w,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.w),
                child: SizedBox(
                  height: 468.w,
                  width: double.infinity,
                  child: _buildVideo(index),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ByText.text(
                  text: titles[index],
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  textColor: ByColor.colorF1,
                ),
                SizedBox(height: 10.w),

                ByText.text(
                  text: subTitles[index],
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                  textColor: ByColor.colorF3,
                ),
                SizedBox(height: 40.w),
                SizedBox(
                  height: 48.w,
                  child: ByWidgetsUtil.gradientBtn(
                    title: '下一步',
                    fontSize: 16.sp,
                    fontWeight: .bold,
                    onClick: () {
                      if (index == 2) {
                        _releaseVideoResources();
                        Get.delete<GuideStepController>(force: true);
                        if (GlobalController.instance.pay.vipList.isNotEmpty) {
                          Get.offAllNamed(
                            Routes.payCenterPage,
                            arguments: {'guide': true, 'isBackHome': true},
                          );
                        } else {
                          Get.offAllNamed(Routes.main);
                        }
                        return;
                      }
                      controller.pageController.animateToPage(
                        controller.currentIndex.value + 1,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                SizedBox(height: 30.w),
                SizedBox(height: 20.w + ByScreenUtils.bottomSafeHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo(int index) {
    if (videoControllers.length <= index ||
        !videoControllers[index].value.isInitialized) {
      return Container(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: videoControllers[index].value.size.width,
        height: videoControllers[index].value.size.height,
        child: VideoPlayer(videoControllers[index]),
      ),
    );
  }
}
