/*
 * @Author: duncy
 * @Date: 2026-04-10 14:01:17
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 14:01:37
 * @FilePath: /ling_bao/lib/profile/record/binding/record_detail_binding.dart
 * @Description: 
 */
import 'package:get/get.dart';
import 'package:ling_bao/profile/record/controller/record_detail_controller.dart';

class RecordDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordDetailController>(() => RecordDetailController());
  }
}
