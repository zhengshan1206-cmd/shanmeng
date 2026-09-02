import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/dialog/diolog_view.dart';
import 'package:ling_bao/core/ui/dialog/loading_dialog.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/video/shared/home_models.dart';

import '../../../core/network/apis.dart';
import '../../../core/network/http_utils.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/user/user.dart';
import '../../integral/bean/video_works_bean.dart';
import '../bean/ai_draw_img_details_bean.dart';
import '../page/profile_page.dart';

class ProfileController extends GetxController {
  final UserController user = Get.find<UserController>();
  final RefreshManager videoRefreshManager = RefreshManager();
  final RefreshManager imageRefreshManager = RefreshManager();

  RxList<VideoWorksBean> videoList = <VideoWorksBean>[].obs;

  RxList<AiDrawImgDetailsBean> imgList = <AiDrawImgDetailsBean>[].obs;
  RxBool videoHasMore = true.obs;
  RxBool imageHasMore = true.obs;

  Rx<GenerateCategory> selectedCategory = GenerateCategory.video.obs;

  RefreshManager get currentRefreshManager =>
      selectedCategory.value == GenerateCategory.video
      ? videoRefreshManager
      : imageRefreshManager;

  bool get currentHasMore => selectedCategory.value == GenerateCategory.video
      ? videoHasMore.value
      : imageHasMore.value;

  @override
  void onInit() {
    reloadData();
    user.reloadUserInfo();
    super.onInit();

    final args = Get.arguments;
    if (args != null) {
      selectedCategory.value = args['type'];
    }
  }

  /// 重载数据
  void reloadData() {
    loadVideoList(true);
    loadAllPictures(isRefresh: true);
  }

  String get customerServiceUrl {
    final String fromProfile = '';
    if (fromProfile.trim().isNotEmpty) {
      return fromProfile;
    }
    return '';
  }

  Future<void> copyUserId(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!Get.context!.mounted) {
      return;
    }
    BotToast.showText(text: '用户 ID 已复制');
  }

  /// 当前类型记录是否为空
  bool recordIsEmpty() {
    if (user.isVisitor) {
      return true;
    }
    if ((selectedCategory.value == .video && videoList.isNotEmpty) ||
        (selectedCategory.value == .image && imgList.isNotEmpty)) {
      return false;
    }
    return true;
  }

  /// 点击进入作品详情
  void openRecord(CreationMode mode, dynamic item) {
    if (mode == .video && item is VideoWorksBean && !item.isSuccess) {
      return;
    }
    if (mode == .image && item.status != 3) {
      return;
    }
    Get.toNamed(Routes.recordDetail, arguments: {'mode': mode, 'item': item});
  }

  void changeCategory(GenerateCategory category) {
    if (selectedCategory.value == category) {
      return;
    }
    selectedCategory.value = category;
    if (category == GenerateCategory.video && videoList.isEmpty) {
      loadVideoList(true);
    }
    if (category == GenerateCategory.image && imgList.isEmpty) {
      loadAllPictures(isRefresh: true);
    }
  }

  void refreshCurrentCategory() {
    if (selectedCategory.value == GenerateCategory.video) {
      loadVideoList(true);
    } else {
      loadAllPictures(isRefresh: true);
    }
  }

  void loadMoreCurrentCategory() {
    if (selectedCategory.value == GenerateCategory.video) {
      loadVideoList(false);
    } else {
      loadAllPictures(isRefresh: false);
    }
  }

  /// 视频列表
  /// [videoQueryType] 数据类型：1仅查询混剪任务 2查询非混剪任务
  void loadVideoList(
    bool isRefresh, {
    void Function()? onSuccess,
    void Function()? onFailed,
  }) {
    final manager = videoRefreshManager;
    if (!manager.beginRequest(isRefresh, hasMore: videoHasMore.value)) {
      return;
    }
    if (isRefresh) {
      videoHasMore.value = true;
    }
    HttpUtils.get(
      APIs.getVideoWorksList,
      {"page": manager.pageHelper.page, "pageSize": manager.pageHelper.row},
      success: (data) {
        final dynamic listData =
            data["data"]?["data"] ?? data["data"]?["items"] ?? [];
        final List items = listData is List ? listData : <dynamic>[];
        final List<VideoWorksBean> works = List<VideoWorksBean>.from(
          items.map(
            (dynamic e) =>
                VideoWorksBean.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
        if (isRefresh) {
          videoList.value = works;
        } else {
          videoList.addAll(works);
        }
        final bool hasMore = works.length >= manager.pageHelper.row;
        videoHasMore.value = hasMore;
        manager.completeSuccess(isRefresh: isRefresh, hasMore: hasMore);
        onSuccess?.call();
      },
      fail: (code, msg) {
        manager.completeFailed(isRefresh);
        onFailed?.call();
        return BotToast.showText(text: msg);
      },
    );
  }

  /// 图片列表
  /// 加载我的作品
  void loadAllPictures({
    bool isRefresh = true,
    void Function()? onSuccess,
    void Function()? onFailed,
  }) {
    final manager = imageRefreshManager;
    if (!manager.beginRequest(isRefresh, hasMore: imageHasMore.value)) {
      return;
    }
    if (isRefresh) {
      imageHasMore.value = true;
    }
    HttpUtils.get(
      APIs.allAiPictures,
      {"page": manager.pageHelper.page, "size": manager.pageHelper.row},
      // showLoading: true,
      success: (data) {
        final workData = data["data"]["items"] ?? [];
        final beans = List<AiDrawImgDetailsBean>.from(
          workData.map((e) => AiDrawImgDetailsBean.fromJson(e)),
        );
        if (isRefresh) {
          imgList.value = beans;
        } else {
          imgList.addAll(beans);
        }
        final bool hasMore = beans.length >= manager.pageHelper.row;
        imageHasMore.value = hasMore;
        manager.completeSuccess(isRefresh: isRefresh, hasMore: hasMore);
        onSuccess?.call();
      },
      fail: (code, msg) {
        manager.completeFailed(isRefresh);
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 删除生成记录
  /// VideoAi/deleteVideoWork
  /// id: 123, video_source: ai_video
  /// QiumiImage/deleteOrders
  /// ids: 123,123
  void deleteRecord({
    required bool isVideo,
    required List<int> ids,
    required int index,
    String videoSource = 'ai_video',
  }) {
    if (ids.isEmpty) {
      Toast.showText(text: '删除参数异常，请稍后重试');
      return;
    }
    Get.dialog(
      NovelDialog(
        content: '您确认要删除这${isVideo ? '条视频' : '张图片'}?',
        onConfirm: () {
          LoadingDialog().show(message: '删除中...');
          final int targetId = ids.first;
          HttpUtils.post(
            isVideo ? APIs.deleteVideoWork : APIs.deleteImages,
            isVideo
                ? {
                    "id": targetId,
                    "video_source": videoSource.trim().isEmpty
                        ? 'ai_video'
                        : videoSource,
                  }
                : {"ids": ids.join(",")},
            showMsgWhenFailed: false,
            success: (data) {
              LoadingDialog().dismiss();
              if (isVideo) {
                videoList.removeWhere((e) => e.id == targetId);
              } else if (index >= 0 && index < imgList.length) {
                imgList.removeAt(index);
              }
            },
            fail: (code, msg) {
              LoadingDialog().dismiss();
              Toast.showText(text: msg);
            },
          );
        },
      ),
    );
  }

  @override
  void onClose() {
    videoRefreshManager.dispose();
    imageRefreshManager.dispose();
    super.onClose();
  }
}
