/*
 * @Author: duncy
 * @Date: 2025-10-30 17:38:46
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 13:48:26
 * @FilePath: /ling_bao/lib/global/launch/controller/guide_step_controller.dart
 * @Description: 
 */

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ling_bao/global/login/controller/onekey_manager.dart';
import 'package:ling_bao/video/main/controller/home_video_controller.dart';

import '../../../core/cache/byhy_aes_storage_utils.dart';
import '../../const/const_string.dart';

class GuideStepController extends GetxController {
  PageController pageController = PageController();

  ///当前index
  RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    final HomeVideoController homeVideoController = Get.put(
      HomeVideoController(),
      permanent: true,
    );
    homeVideoController.fetchHotRecommend(isFirst: true);

    ByStorageUtils.saveBool(ConstString.kLaunchGuideCheck, true);
    OneKeyManager.init();
    super.onInit();
  }
}
