/*
 * @Author: duncy
 * @Date: 2025-10-13 14:39:33
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-28 16:53:20
 * @FilePath: /novel_oversea/lib/global/pay/binding/pay_binding.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:ling_bao/global/pay/controller/pay_controller.dart';

class PayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayController>(() => PayController());
  }
}
