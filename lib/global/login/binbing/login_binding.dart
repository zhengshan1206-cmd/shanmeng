/*
 * @Author: duncy
 * @Date: 2025-12-16 14:35:11
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-09 10:09:44
 * @FilePath: /ling_bao/lib/global/login/binbing/login_binding.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:ling_bao/global/login/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments ?? {};
    Get.put<LoginController>(
      LoginController(
        onLoginSuccessCallback: args["onLoginSuccess"],
        isBindMode: args['bind'] ?? false,
        // source: args['source'] ?? 'normal',
      ),
    );
  }
}
