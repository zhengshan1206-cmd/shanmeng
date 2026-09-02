import 'dart:async';

/*
 * @Author: duncy
 * @Date: 2026-04-08 16:33:44
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-06-03 09:41:09
 * @FilePath: /ling_bao/lib/video/main/controller/video_detail_controller.dart
 * @Description: 分类「查看全部」：分享图 squareByCategory + 分享视频 getAiVideoCategoryDetail
 */
import 'package:get/get.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/core/network/http_utils.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/video/main/bean/video_face_fusion_template_bean.dart';

import '../../../profile/main/bean/ai_draw_img_details_bean.dart';
import '../../../profile/main/bean/ai_video_square_model.dart';

/// 分类二级页展示范围（与首页入口一致，避免图/视频模块互相串数据）
enum VideoDetailListScope { image, video, both }

class VideoDetailController extends GetxController {
  final RefreshManager refreshManager = RefreshManager();
  final RefreshManager videoRefreshManager = RefreshManager();
  final RefreshManager mixedRefreshManager = RefreshManager();

  /// 分享视频模板（VideoFaceFusion/getTemplateList）
  RxList<VideoFaceFusionTemplateBean> hotList =
      <VideoFaceFusionTemplateBean>[].obs;

  /// 分享图
  RxList<AiDrawImgDetailsBean> hotImagesList = <AiDrawImgDetailsBean>[].obs;
  RxBool imageHasMore = true.obs;
  RxBool videoHasMore = true.obs;

  RxInt index = 0.obs;

  String cateTitle = '';
  int cateID = 0;

  /// 由路由 `listScope` 或入参列表推断；默认仅图（兼容旧入口）
  VideoDetailListScope listScope = VideoDetailListScope.image;

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map) {
      final int safeIndex = (args['index'] as num?)?.toInt() ?? 0;
      index.value = safeIndex;

      cateID = (args['id'] as num?)?.toInt() ?? 0;
      cateTitle = args['title']?.toString() ?? '';

      final dynamic videoArg = args['video'];
      if (videoArg is List) {
        final videos = videoArg
            .map((item) {
              if (item is VideoFaceFusionTemplateBean) return item;
              if (item is AiVideoSquareModel) {
                return VideoFaceFusionTemplateBean.fromLegacyModel(item);
              }
              if (item is Map) {
                final Map<String, dynamic> json = Map<String, dynamic>.from(
                  item,
                );
                if (json.containsKey('source_video_url') ||
                    json.containsKey('source_cover_url')) {
                  return VideoFaceFusionTemplateBean.fromJson(json);
                }
                try {
                  final legacy = AiVideoSquareModel.fromJson(json);
                  return VideoFaceFusionTemplateBean.fromLegacyModel(legacy);
                } catch (_) {
                  return null;
                }
              }
              return null;
            })
            .whereType<VideoFaceFusionTemplateBean>()
            .toList();
        hotList.addAll(videos);
      }

      final dynamic imageArg = args['image'];
      if (imageArg is List) {
        final images = imageArg
            .map((item) {
              if (item is AiDrawImgDetailsBean) return item;
              if (item is Map) {
                return AiDrawImgDetailsBean.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }
              return null;
            })
            .whereType<AiDrawImgDetailsBean>()
            .toList();
        hotImagesList.addAll(images);
      }

      listScope = _parseListScope(Map<dynamic, dynamic>.from(args));

      switch (listScope) {
        case VideoDetailListScope.image:
          hotList.clear();
          break;
        case VideoDetailListScope.video:
          hotImagesList.clear();
          break;
        case VideoDetailListScope.both:
          break;
      }

      final int maxLen = switch (listScope) {
        VideoDetailListScope.image => hotImagesList.length,
        VideoDetailListScope.video => hotList.length,
        VideoDetailListScope.both =>
          hotList.isNotEmpty ? hotList.length : hotImagesList.length,
      };
      if (maxLen > 0 && index.value >= maxLen) {
        index.value = maxLen - 1;
      }
    }
    if (cateID > 0) {
      if (listScope == VideoDetailListScope.image ||
          listScope == VideoDetailListScope.both) {
        fetchHotImages(true);
      }
      if (listScope == VideoDetailListScope.video ||
          listScope == VideoDetailListScope.both) {
        fetchHotVideos(true);
      }
    }
    super.onInit();
  }

  static bool _listArgEmpty(dynamic v) => v == null || (v is List && v.isEmpty);

  static VideoDetailListScope _parseListScope(Map<dynamic, dynamic> args) {
    final String? raw =
        args['listScope']?.toString() ?? args['contentScope']?.toString();
    if (raw == 'image' || raw == '0') {
      return VideoDetailListScope.image;
    }
    if (raw == 'video' || raw == '1') {
      return VideoDetailListScope.video;
    }
    if (raw == 'both' || raw == '2') {
      return VideoDetailListScope.both;
    }
    final bool imgEmpty = _listArgEmpty(args['image']);
    final bool vidEmpty = _listArgEmpty(args['video']);
    if (!vidEmpty && imgEmpty) {
      return VideoDetailListScope.video;
    }
    if (vidEmpty && !imgEmpty) {
      return VideoDetailListScope.image;
    }
    if (!vidEmpty && !imgEmpty) {
      return VideoDetailListScope.both;
    }
    return VideoDetailListScope.image;
  }

  /// 图片列表分页
  void fetchHotImages(
    bool isRefresh, {
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
    bool notifyRefreshUi = true,
    void Function()? onComplete,
  }) {
    if (cateID <= 0) {
      onComplete?.call();
      return;
    }
    final manager = refreshManager;
    if (!manager.beginRequest(isRefresh, hasMore: imageHasMore.value)) {
      onComplete?.call();
      return;
    }
    if (isRefresh) {
      imageHasMore.value = true;
    }
    HttpUtils.get(
      'api/QiumiImage/squareByCategory',
      <String, dynamic>{
        'page': manager.pageHelper.page,
        'size': manager.pageHelper.row,
        'category_id': cateID,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List items = data['data']?['items'] ?? [];
        final beans = List<AiDrawImgDetailsBean>.from(
          items.map(
            (ele) => AiDrawImgDetailsBean.fromJson(
              Map<String, dynamic>.from(ele as Map),
            ),
          ),
        );
        if (isRefresh) {
          hotImagesList.value = beans;
        } else {
          hotImagesList.addAll(beans);
        }
        final bool hasMore = beans.length >= manager.pageHelper.row;
        imageHasMore.value = hasMore;
        manager.completeSuccess(
          isRefresh: isRefresh,
          hasMore: hasMore,
          notifyRefreshUi: notifyRefreshUi,
        );
        onSuccess?.call(data);
        onComplete?.call();
      },
      fail: (code, msg) {
        manager.completeFailed(isRefresh, notifyRefreshUi: notifyRefreshUi);
        Toast.showText(text: msg);
        onFail?.call(code, msg);
        onComplete?.call();
      },
    );
  }

  /// 视频模板列表分页（VideoFaceFusion/getTemplateList）
  void fetchHotVideos(
    bool isRefresh, {
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
    bool notifyRefreshUi = true,
    void Function()? onComplete,
  }) {
    if (cateID <= 0) {
      onComplete?.call();
      return;
    }
    final manager = videoRefreshManager;
    if (!manager.beginRequest(isRefresh, hasMore: videoHasMore.value)) {
      onComplete?.call();
      return;
    }
    if (isRefresh) {
      videoHasMore.value = true;
    }
    HttpUtils.get(
      APIs.getTemplateList,
      <String, dynamic>{
        'page': manager.pageHelper.page,
        'pageSize': manager.pageHelper.row,
        'category_id': cateID,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List items = data['data']?['data'] ?? <dynamic>[];
        final beans = List<VideoFaceFusionTemplateBean>.from(
          items.map(
            (dynamic e) => VideoFaceFusionTemplateBean.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
        if (isRefresh) {
          hotList.value = beans;
        } else {
          hotList.addAll(beans);
        }
        final bool hasMore = beans.length >= manager.pageHelper.row;
        videoHasMore.value = hasMore;
        manager.completeSuccess(
          isRefresh: isRefresh,
          hasMore: hasMore,
          notifyRefreshUi: notifyRefreshUi,
        );
        onSuccess?.call(data);
        onComplete?.call();
      },
      fail: (code, msg) {
        manager.completeFailed(isRefresh, notifyRefreshUi: notifyRefreshUi);
        Toast.showText(text: msg);
        onFail?.call(code, msg);
        onComplete?.call();
      },
    );
  }

  /// 同时下拉刷新图、视频（不触发各自 SmartRefresher 的 footer 逻辑）
  Future<void> reloadAll() async {
    if (cateID <= 0) return;
    if (listScope == VideoDetailListScope.image) {
      final Completer<void> done = Completer<void>();
      fetchHotImages(
        true,
        notifyRefreshUi: false,
        onComplete: () {
          if (!done.isCompleted) done.complete();
        },
      );
      return done.future;
    }
    if (listScope == VideoDetailListScope.video) {
      final Completer<void> done = Completer<void>();
      fetchHotVideos(
        true,
        notifyRefreshUi: false,
        onComplete: () {
          if (!done.isCompleted) done.complete();
        },
      );
      return done.future;
    }
    final Completer<void> done = Completer<void>();
    int pending = 2;
    void tick() {
      pending--;
      if (pending <= 0 && !done.isCompleted) {
        done.complete();
      }
    }

    fetchHotImages(true, notifyRefreshUi: false, onComplete: tick);
    fetchHotVideos(true, notifyRefreshUi: false, onComplete: tick);
    return done.future;
  }

  /// 混合列表下拉刷新（供 ByRefresh 使用）
  Future<void> refreshForMixedList() async {
    if (!mixedRefreshManager.beginRequest(true, hasMore: true)) {
      return;
    }

    bool hasFailure = false;
    int pending = 0;

    void tick() {
      pending--;
      if (pending <= 0) {
        if (hasFailure) {
          mixedRefreshManager.completeFailed(true);
        } else {
          mixedRefreshManager.completeSuccess(
            isRefresh: true,
            hasMore: imageHasMore.value || videoHasMore.value,
          );
        }
      }
    }

    pending++;
    fetchHotImages(
      true,
      notifyRefreshUi: false,
      onFail: (_, __) {
        hasFailure = true;
      },
      onComplete: tick,
    );

    pending++;
    fetchHotVideos(
      true,
      notifyRefreshUi: false,
      onFail: (_, __) {
        hasFailure = true;
      },
      onComplete: tick,
    );
  }

  /// 混合列表上拉加载（供 ByRefresh 使用）
  Future<void> loadMoreForMixedList() async {
    final bool canLoadMore = imageHasMore.value || videoHasMore.value;
    if (!mixedRefreshManager.beginRequest(false, hasMore: canLoadMore)) {
      return;
    }

    bool hasFailure = false;
    int pending = 0;

    void tick() {
      pending--;
      if (pending <= 0) {
        if (hasFailure) {
          mixedRefreshManager.completeFailed(false);
        } else {
          mixedRefreshManager.completeSuccess(
            isRefresh: false,
            hasMore: imageHasMore.value || videoHasMore.value,
          );
        }
      }
    }

    if (imageHasMore.value) {
      pending++;
      fetchHotImages(
        false,
        notifyRefreshUi: false,
        onFail: (_, __) {
          hasFailure = true;
        },
        onComplete: tick,
      );
    }

    if (videoHasMore.value) {
      pending++;
      fetchHotVideos(
        false,
        notifyRefreshUi: false,
        onFail: (_, __) {
          hasFailure = true;
        },
        onComplete: tick,
      );
    }

    if (pending == 0) {
      mixedRefreshManager.completeSuccess(isRefresh: false, hasMore: false);
    }
  }

  @override
  void onClose() {
    refreshManager.dispose();
    videoRefreshManager.dispose();
    mixedRefreshManager.dispose();
    super.onClose();
  }
}
