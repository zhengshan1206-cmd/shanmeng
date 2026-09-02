/*
 * @Author: duncy
 * @Date: 2026-04-08 16:58:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-09 12:11:55
 * @FilePath: /ling_bao/lib/create/create_binding.dart
 * @Description: 
 */
import 'package:get/get.dart';
import 'package:ling_bao/create/create_controller.dart';

class CreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateController>(() => CreateController());
  }
}
