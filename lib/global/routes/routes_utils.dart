/*
 * @Author: duncy
 * @Date: 2026-05-11 11:38:44
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-11 11:52:59
 * @FilePath: /ling_bao/lib/global/routes/routes_utils.dart
 * @Description: 
 */
import 'package:get/get.dart';

import '../../create/home_create_type_dialog.dart';
import '../../video/main/bean/home_banner_bean.dart';
import 'app_pages.dart';

class RoutesUtils {
  /// banner跳转
  static void bannerTap(HomeBannerBean bean) {
    if (bean.jumpUrl!.isNotEmpty) {
      switch (bean.jumpUrl!) {
        /// 创作页
        case '/create':
          final int type = bean.type;
          final CreateTypeEntryData entry = createTypeEntries
              .where((e) => e.bannerId == type)
              .first;
          Get.toNamed(Routes.create, arguments: {'entry': entry});
          break;

        /// 创作同款图片
        case '/case_create_image':
          Get.toNamed(
            Routes.caseCreate,
            arguments: <String, dynamic>{
              'index': 0,
              'is_video': false,
              'id': int.parse(bean.jumpParam!),
              'title': bean.title,
            },
          );
          break;

        /// 创作同款视频
        case '/case_create_video':
          Get.toNamed(
            Routes.caseCreate,
            arguments: <String, dynamic>{
              'index': 0,
              'is_video': true,
              'id': int.parse(bean.jumpParam!),
              'title': bean.title,
            },
          );
          break;
      }
    }
  }
}
