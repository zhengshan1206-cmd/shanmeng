/*
 * @Author: duncy
 * @Date: 2026-04-13 15:08:26
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-15 15:38:19
 * @FilePath: /ling_bao/lib/image/home_image_controller.dart
 * @Description: 
 */

import 'package:get/get.dart';
import 'package:ling_bao/image/bean/image_category_bean.dart';

import '../core/network/http_utils.dart';
import '../profile/main/bean/ai_draw_img_details_bean.dart';

class HomeImageController extends GetxController {
  RxMap<String, List> items = <String, List>{}.obs;
  RxList<ImageCategoryBean> categries = <ImageCategoryBean>[].obs;

  @override
  void onInit() {
    fetchCategory();
    super.onInit();
  }

  /// 获取分类
  void fetchCategory() {
    HttpUtils.get(
      'api/comConfig/getCategoryList',
      {'type': 'ai_image'},
      success: (data) {
        final workData = data["data"] ?? [];
        final beans = List<ImageCategoryBean>.from(
          workData.map((e) => ImageCategoryBean.fromJson(e)),
        );
        categries.clear();
        categries.addAll(beans);
        for (final ImageCategoryBean bean in beans) {
          fetchCategoryDetail(id: bean.id!);
        }
      },
    );
  }

  /// 获取分类详情
  void fetchCategoryDetail({required int id}) {
    HttpUtils.get(
      'api/QiumiImage/squareByCategory',
      {'category_id': id, 'page': 1, 'size': 10},
      success: (data) {
        final workData = data["data"]["items"];
        final beans = List<AiDrawImgDetailsBean>.from(
          workData.map((e) => AiDrawImgDetailsBean.fromJson(e)),
        );
        items[id.toString()] = beans;
      },
    );
  }
}
