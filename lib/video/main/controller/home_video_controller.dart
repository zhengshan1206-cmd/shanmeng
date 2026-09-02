/*
 * @Author: duncy
 * @Date: 2026-04-08 14:53:53
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-06-04 10:31:51
 * @FilePath: /ling_bao/lib/video/main/controller/home_video_controller.dart
 * @Description: AI 视频首页：分类 + 分类下分享图 / 分享视频（对齐图片首页数据链路）
 */
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/cache/daily_cache_manager.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/ui/view/by_common_utils.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/create/home_create_category_page.dart';
import 'package:ling_bao/global/const/const_string.dart';
import 'package:ling_bao/global/main/main_controller.dart';
import 'package:ling_bao/image/bean/image_category_bean.dart';
import 'package:ling_bao/profile/main/bean/ai_draw_img_details_bean.dart';
import 'package:ling_bao/video/main/bean/home_banner_bean.dart';
import 'package:ling_bao/video/main/bean/recommend_simple_bean.dart';
import 'package:ling_bao/video/main/bean/video_face_fusion_template_bean.dart';
import 'package:ling_bao/video/main/view/home_video_dialog.dart';

import '../../../core/cache/byhy_aes_storage_utils.dart';
import '../../../core/network/http_utils.dart';
import '../../../core/util/util.dart';
import '../../../global/routes/app_pages.dart';

class HomeVideoController extends GetxController {
  /// `getCategoryList` type=ai_video
  RxList<ImageCategoryBean> videoCategories = <ImageCategoryBean>[].obs;

  /// 分类 id -> `QiumiImage/squareByCategory` 列表
  RxMap<String, List> imageItems = <String, List>{}.obs;

  /// 分类 id -> `VideoFaceFusion/getTemplateList` 列表
  RxMap<String, List> videoItems = <String, List>{}.obs;

  /// banner
  RxList<HomeBannerBean> bannerList = <HomeBannerBean>[].obs;

  /// loading状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusLoading.obs;

  @override
  void onInit() {
    bool firstIn =
        ByStorageUtils.getBool(ConstString.kUserEnteredHomePage) ?? false;
    fetchCategory(isFirst: !firstIn);
    fetchBannerData();
    ByStorageUtils.saveBool(ConstString.kUserEnteredHomePage, true);
    super.onInit();
  }

  /// 点击AI视频
  void toggleVideo() {
    Get.to(() => const CreateCategoryPage(title: 'AI视频', category: .video));
  }

  /// 点击AI图片
  void toggleImage() {
    final MainController main = Get.find<MainController>();
    main.tabChanged(2);
  }

  /// 查看某分类下全部（图 + 视频）
  void openCategoryMore(ImageCategoryBean section) {
    final String idKey = section.id?.toString() ?? '';
    final dynamic rawImg = imageItems[idKey];
    final dynamic rawVid = videoItems[idKey];
    final List<AiDrawImgDetailsBean> imgSnap = rawImg is List
        ? List<AiDrawImgDetailsBean>.from(rawImg.cast<AiDrawImgDetailsBean>())
        : <AiDrawImgDetailsBean>[];
    final List<VideoFaceFusionTemplateBean> vidSnap = rawVid is List
        ? List<VideoFaceFusionTemplateBean>.from(
            rawVid.cast<VideoFaceFusionTemplateBean>(),
          )
        : <VideoFaceFusionTemplateBean>[];
    Get.toNamed(
      Routes.videoDetail,
      arguments: <String, dynamic>{
        'index': 0,
        'image': imgSnap,
        'video': vidSnap,
        'title': section.title ?? '',
        'id': section.id ?? 0,
        'key': section.key,
        // 二级页只展示视频列表；图片接口数据仍可从路由带入创作页等，不在此页展示
        'listScope': 'video',
      },
    );
  }

  List<RecommendSimpleBean> recommendList = [];

  /// 显示弹窗推荐
  void showRecommendDialog() async {
    bool showDialog = await DailyManager.shouldShowPopup(
      ConstString.kHomeRecommendDialog,
    );
    if (recommendList.isEmpty || !showDialog) {
      return;
    }
    DailyManager.recordPopupDate(ConstString.kHomeRecommendDialog);
    Get.dialog(
      HomeVideoDialog(dataList: recommendList),
      barrierDismissible: false,
    );
  }

  /// 获取弹窗推荐视频
  void fetchHotRecommend({bool isFirst = false}) {
    HttpUtils.get(
      APIs.getRecommendList,
      <String, dynamic>{'page': 1, 'size': 5},
      showMsgWhenFailed: false,
      success: (data) async {
        final List items = data['data']?['data'] ?? <dynamic>[];
        final beans = List<RecommendSimpleBean>.from(
          items.map(
            (dynamic e) => RecommendSimpleBean.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
        recommendList = beans;
        if (!isFirst) {
          showRecommendDialog();
        } else {
          for (final RecommendSimpleBean bean in beans) {
            if (bean.previewVideoUrl != null) {
              await CachedVideoPlayerPlus.preCacheVideo(
                Uri.parse(bean.previewVideoUrl!),
                invalidateCacheIfOlderThan: const Duration(days: 30),
              );
              if (bean.coverUrl != null && bean.coverUrl!.isNotEmpty) {
                ByCommonUtils.precacheGifUrl(bean.coverUrl!);
              }
              print('_____缓存视频：：：：${bean.previewVideoUrl!}');
            }
          }
        }
      },
    );
  }

  /// 获取 AI 视频模块分类
  void fetchCategory({bool isFirst = false}) {
    statusType.value = MultiStatusType.statusLoading;
    HttpUtils.get(
      'api/comConfig/getCategoryList',
      <String, dynamic>{'type': 'video_face_fusion'},
      success: (data) {
        final dynamic workData = data['data'] ?? [];
        final beans = <ImageCategoryBean>[];
        statusType.value = MultiStatusType.statusContent;
        if (workData is List) {
          for (final dynamic e in workData) {
            if (e is ImageCategoryBean) {
              beans.add(e);
            } else if (e is Map) {
              beans.add(
                ImageCategoryBean.fromJson(Map<String, dynamic>.from(e)),
              );
            }
          }
        }
        videoCategories.clear();
        videoCategories.addAll(beans);
        for (final ImageCategoryBean bean in beans) {
          final int? id = bean.id;
          if (id == null) continue;
          fetchCategoryVideoList(categoryId: id, isFirst: isFirst);
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusError;
      },
    );
  }

  /// 分类下分享图片列表
  // void fetchCategoryImageList({required int categoryId}) {
  //   HttpUtils.get(
  //     'api/QiumiImage/squareByCategory',
  //     <String, dynamic>{'category_id': categoryId, 'page': 1, 'size': 10},
  //     showMsgWhenFailed: false,
  //     success: (data) {
  //       final workData = data['data']?['items'] ?? [];
  //       final beans = List<AiDrawImgDetailsBean>.from(
  //         (workData as List).map(
  //           (dynamic e) => AiDrawImgDetailsBean.fromJson(
  //             Map<String, dynamic>.from(e as Map),
  //           ),
  //         ),
  //       );
  //       imageItems[categoryId.toString()] = beans;
  //     },
  //   );
  // }

  /// 分类下模板视频列表（VideoFaceFusion/getTemplateList）
  void fetchCategoryVideoList({required int categoryId, bool isFirst = false}) {
    HttpUtils.get(
      APIs.getTemplateList,
      <String, dynamic>{'page': 1, 'pageSize': 10, 'category_id': categoryId},
      showMsgWhenFailed: false,
      success: (data) async {
        final List items = data['data']?['data'] ?? <dynamic>[];
        final beans = List<VideoFaceFusionTemplateBean>.from(
          items.map(
            (dynamic e) => VideoFaceFusionTemplateBean.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
        if (isFirst) {
          final List<String> gifs = beans
              .where((e) => Util.isGif(e.miniPreviewVideoUrl))
              .map((e) => e.miniPreviewVideoUrl)
              .toList();
          await ByCommonUtils.precacheGifUrls(gifs.take(3).toList());
          ByCommonUtils.precacheGifUrls(gifs.skip(3).toList());
        }
        videoItems[categoryId.toString()] = beans;
      },
    );
  }

  /// 获取banner位配置数据
  void fetchBannerData() {
    HttpUtils.get(
      APIs.homeBanner,
      {'postion': 15},
      success: (data) {
        final List items = data['data']?['item'] ?? <dynamic>[];
        final beans = List<HomeBannerBean>.from(
          items.map(
            (dynamic e) =>
                HomeBannerBean.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
        bannerList.clear();
        bannerList.addAll(beans);
      },
    );
  }
}
