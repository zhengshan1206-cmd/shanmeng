/*
 * @Author: duncy
 * @Date: 2026-04-08 16:58:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-08 16:59:55
 * @FilePath: /ling_bao/lib/video/main/binding/video_create_binding.dart
 * @Description: 
 */
import 'package:get/get.dart';
import 'package:ling_bao/video/main/controller/video_create_controller.dart';

class VideoCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoCreateController>(() => VideoCreateController());
  }
}
