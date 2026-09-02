/*
 * @Author: duncy
 * @Date: 2026-04-13 13:49:11
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 13:59:11
 * @FilePath: /ling_bao/lib/profile/integral/binding/intergral_record_binding.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:ling_bao/profile/integral/controller/intergral_record_controller.dart';

class IntergralRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IntergralRecordController>(() => IntergralRecordController());
  }
}
