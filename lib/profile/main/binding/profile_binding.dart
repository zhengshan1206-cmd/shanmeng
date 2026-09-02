/*
 * @Author: duncy
 * @Date: 2026-04-08 16:58:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 14:01:39
 * @FilePath: /ling_bao/lib/profile/main/binding/profile_binding.dart
 * @Description: 
 */
import 'package:get/get.dart';

import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
