import 'package:ling_bao/image/bean/image_category_bean.dart';

/// `VideoAi/getAiVideoCategoryDetail` 的 `type`：1 文生视频 / 2 图生视频。
///
/// 独立小工具，供视频首页与「查看全部」详情共用，避免 Controller 互相引用影响其它模块。
int videoSquareRequestTypeForCategory(ImageCategoryBean bean) {
  final String title = (bean.title ?? '').toLowerCase();
  final String key = (bean.key ?? '').toLowerCase();
  if (title.contains('文生') ||
      key.contains('text') ||
      key.contains('wen') ||
      key.contains('txt')) {
    return 1;
  }
  return 2;
}
