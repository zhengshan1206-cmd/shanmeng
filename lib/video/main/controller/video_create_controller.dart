/*
 * @Author: duncy
 * @Date: 2026-04-08 16:33:44
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-13 19:46:53
 * @FilePath: /ling_bao/lib/video/main/controller/video_create_controller.dart
 * @Description: 
 */
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/common/by_ffmpeg_util.dart';
import 'package:ling_bao/core/network/apis.dart';
import 'package:ling_bao/global/other/right_manager.dart';
import 'package:ling_bao/profile/main/page/profile_page.dart';
import 'package:ling_bao/video/main/bean/video_face_fusion_template_bean.dart';
import '../../../core/ui/view/by_common_utils.dart';
import '../../../core/network/http_utils.dart';
import '../../../core/ui/dialog/loading_dialog.dart';
import '../../../core/ui/dialog/toast.dart';
import '../../../create/create_controller.dart';
import '../../../global/pay/bean/pay_preview_media.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/user/user.dart';
import '../../../profile/main/bean/ai_draw_img_details_bean.dart';
import '../../../profile/main/bean/ai_video_square_model.dart';

class VideoCreateController extends GetxController {
  static const String _templateRightsType = 'video_face_fusion_template';
  static const String _imageTemplateRightsType = 'ai_qiumi_paint';

  CreateFlowType type = CreateFlowType.aiDraw;

  /// 热门列表
  RxList<AiVideoSquareModel> hotList = <AiVideoSquareModel>[].obs;
  RxList<VideoFaceFusionTemplateBean> templateHotList =
      <VideoFaceFusionTemplateBean>[].obs;
  RxList<AiDrawImgDetailsBean> hotImagesList = <AiDrawImgDetailsBean>[].obs;

  /// 权益
  var rights = Rx<RightBean?>(null);

  /// 当前选择的序列
  RxInt index = 0.obs;

  /// 图生视频 / 图生图「创作同款」上传成功后的图片地址
  RxString uploadedImageUrl = ''.obs;
  RxBool uploadingImage = false.obs;

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map) {
      final int safeIndex = (args['index'] as num?)?.toInt() ?? 0;
      index.value = safeIndex;
      final dynamic videoArg = args['video'];
      if (videoArg is List) {
        final videos = videoArg
            .map((item) {
              if (item is AiVideoSquareModel) return item;
              if (item is Map) {
                return AiVideoSquareModel.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }
              return null;
            })
            .whereType<AiVideoSquareModel>()
            .toList();
        hotList.addAll(videos);
      }

      final dynamic templateVideoArg = args['video_templates'];
      if (templateVideoArg is List) {
        final templates = templateVideoArg
            .map((item) {
              if (item is VideoFaceFusionTemplateBean) return item;
              if (item is Map) {
                return VideoFaceFusionTemplateBean.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }
              return null;
            })
            .whereType<VideoFaceFusionTemplateBean>()
            .toList();
        templateHotList.addAll(templates);
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

      final int maxLen = templateHotList.isNotEmpty
          ? templateHotList.length
          : (hotList.isNotEmpty ? hotList.length : hotImagesList.length);
      if (maxLen > 0 && index.value >= maxLen) {
        index.value = maxLen - 1;
      }

      final cateID = (args['id'] as num?)?.toInt() ?? 0;
      final isVideo = args['is_video'];
      if (cateID > 0) {
        isVideo ? fetchHotVideos(cateID) : fetchHotImages(cateID);
      } else {
        _decideType();
      }
    }

    super.onInit();
  }

  /// 定义权益与模版类型
  void _decideType() {
    // “写同款”页面可承载图/视频两种数据，这里按实际类型切换权益，
    // 避免视频场景误用文生图积分配置。
    type = (isVideo() || isTemplateVideoMode)
        ? CreateFlowType.imageToVideo
        : CreateFlowType.aiDraw;
    _getRights();
  }

  /// 是否是视频制作
  bool isVideo() {
    return hotList.isEmpty && templateHotList.isEmpty ? false : true;
  }

  /// 获取消耗积分
  int integralRights() {
    if (rights.value != null) {
      if (rights.value!.freeCount! > 0) {
        return 0;
      }
      return rights.value?.configIntegral ?? 0;
    } else {
      return 0;
    }
  }

  /// 模板视频同款（VideoFaceFusion/getTemplateList）
  bool get isTemplateVideoMode => templateHotList.isNotEmpty;

  AiVideoSquareModel? get currentVideoModel {
    if (!isVideo() || index.value < 0 || index.value >= hotList.length) {
      return null;
    }
    return hotList[index.value];
  }

  VideoFaceFusionTemplateBean? get currentTemplateVideoModel {
    if (!isTemplateVideoMode ||
        index.value < 0 ||
        index.value >= templateHotList.length) {
      return null;
    }
    return templateHotList[index.value];
  }

  AiDrawImgDetailsBean? get currentImageModel {
    if (isVideo() || index.value < 0 || index.value >= hotImagesList.length) {
      return null;
    }
    return hotImagesList[index.value];
  }

  /// 仅图生视频“创作同款”需要用户先上传自己的图片
  bool shouldUseUploadedImageFlow() {
    return currentVideoModel?.type == AiVideoGenerationType.imageToVideo;
  }

  /// 图片同款：generate_type 1 文生图 / 2 图生图（图生图需先选图上传，与图生视频同款一致）
  bool shouldUseImageUploadFlow() {
    final AiDrawImgDetailsBean? m = currentImageModel;
    if (m == null) return false;
    return AiDrawImgDetailsBean.parseGenerateType(m.generateType) == 2;
  }

  /// 切换模板时清空已上传地址，避免串单
  void onTemplateIndexChanged() {
    uploadedImageUrl.value = '';
    _getRights();
  }

  /// 用户积分
  int getUserIntegral() {
    return Get.find<UserController>().userInfoBean.value?.integral ?? 0;
  }

  /// 立即创作
  void create() {
    if (uploadingImage.value) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }
    if (isTemplateVideoMode) {
      _pickUploadThen(generateTemplateVideo);
      return;
    }
    // 图生视频 / 图生图：与「先相册选图 → 上传 → 再调接口」链路一致
    if (shouldUseUploadedImageFlow()) {
      _pickUploadThen(generateVideo);
      return;
    }
    if (shouldUseImageUploadFlow()) {
      _pickUploadThen(generateImage);
      return;
    }
    isVideo() ? generateVideo() : generateImage();
  }

  void _pickUploadThen(void Function() onSuccess) {
    uploadImage(
      onSuccess: (String url) {
        uploadedImageUrl.value = url;
        onSuccess();
      },
    );
  }

  /// 上传图片
  void uploadImage({Function(String url)? onSuccess}) {
    if (uploadingImage.value) return;
    ByCommonUtils.pickAssetsByType(
      Get.context!,
      type: .image,
      maxCount: 1,
      onSelectedCallback: (assets) async {
        if (assets.isEmpty) return;
        File? file = await assets.first.file;
        if (file == null) return;
        final String? validationError = ByCommonUtils.validateImageFile(file);
        if (validationError != null) {
          BotToast.showText(text: validationError);
          return;
        }
        uploadingImage.value = true;
        ByFfmpegUtil.loadUploadInfo(
          type: MediaType.picture,
          onSuccess: (UploadInfoBean infoBean) {
            ByFfmpegUtil.uploadFile(
              infoBean: infoBean,
              filePath: file.path,
              onSuccess: (resp) {
                ByFfmpegUtil.contentsRisk(
                  url: infoBean.objectUrl,
                  onSuccess: () {
                    uploadingImage.value = false;
                    onSuccess?.call(infoBean.objectUrl);
                  },
                  onFailed: () {
                    uploadingImage.value = false;
                  },
                );
              },
              onFailed: () {
                uploadingImage.value = false;
              },
            );
          },
          onFailed: () {
            uploadingImage.value = false;
          },
        );
      },
    );
  }

  void clearUploadedImage() {
    uploadedImageUrl.value = '';
  }

  PayPreviewPayload? buildPayPreviewPayload() {
    if (isVideo()) {
      final AiVideoSquareModel? model = currentVideoModel;
      if (model == null) return null;
      final String previewVideoUrl = model.shareVideoUrl.isNotEmpty
          ? model.shareVideoUrl
          : model.videoUrl;
      final String previewCoverUrl = model.shareCoverUrl.isNotEmpty
          ? model.shareCoverUrl
          : model.coverUrl;
      return PayPreviewPayload(
        layout: PayPreviewLayout.videoList,
        items: <PayPreviewMedia>[
          PayPreviewMedia(
            coverUrl: previewCoverUrl,
            videoUrl: previewVideoUrl,
            aspectRatio: model.aspectRatio.replaceAll('/', ':'),
          ),
        ],
      );
    }

    if (isTemplateVideoMode) {
      final VideoFaceFusionTemplateBean? model = currentTemplateVideoModel;
      if (model == null) return null;
      final String previewCoverUrl = model.previewCoverUrl.isNotEmpty
          ? model.previewCoverUrl
          : model.sourceCoverUrl;
      final String previewVideoUrl = model.previewVideoUrl.isNotEmpty
          ? model.previewVideoUrl
          : model.sourceVideoUrl;
      return PayPreviewPayload(
        layout: PayPreviewLayout.videoList,
        items: <PayPreviewMedia>[
          PayPreviewMedia(
            coverUrl: previewCoverUrl,
            videoUrl: previewVideoUrl,
            aspectRatio: '4:3',
          ),
        ],
      );
    }

    final AiDrawImgDetailsBean? imageModel = currentImageModel;
    if (imageModel == null) return null;
    return PayPreviewPayload(
      layout: PayPreviewLayout.background,
      items: <PayPreviewMedia>[
        PayPreviewMedia(
          coverUrl: imageModel.picUrl,
          videoUrl: imageModel.normalizedPreviewVideoUrl,
          aspectRatio: imageModel.ratio,
        ),
      ],
    );
  }

  void openPayPageWithPreview() {
    final PayPreviewPayload? payload = buildPayPreviewPayload();
    Get.find<UserController>().jumpToPayPage(
      url: payload?.backgroundUrl ?? '',
      previewPayload: payload,
    );
  }

  /// 获取权益
  void _getRights() {
    final String rightsType = _resolveCurrentRightsType();
    RightManager.fetchRights(
      type: rightsType,
      onSuccess: (bean) {
        rights.value = bean;
      },
    );
  }

  /// 三类“创作同款”共用同一页，权益必须始终跟随当前选中的模板类型：
  /// 图片模板固定走 ai_qiumi_paint，老视频模板按视频类型分流，
  /// 新模板视频直接使用接口下发的 templateType。
  String _resolveCurrentRightsType() {
    if (isTemplateVideoMode) {
      final String rawType =
          currentTemplateVideoModel?.templateType.trim() ?? '';
      return rawType.isNotEmpty ? rawType : _templateRightsType;
    }

    final AiVideoSquareModel? videoModel = currentVideoModel;
    if (videoModel != null) {
      return _videoRightsType(videoModel.type);
    }

    if (currentImageModel != null) {
      return _imageTemplateRightsType;
    }

    return type.rights;
  }

  String _videoRightsType(AiVideoGenerationType type) {
    switch (type) {
      case AiVideoGenerationType.textToVideo:
        return CreateFlowType.textToVideo.rights;
      case AiVideoGenerationType.imageToVideo:
      case AiVideoGenerationType.embraceVideo:
      case AiVideoGenerationType.firstAndEndFrame:
      case AiVideoGenerationType.multipleImages:
        return CreateFlowType.imageToVideo.rights;
    }
  }

  /// 图片列表分页
  void fetchHotImages(
    int cateID, {
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
  }) {
    if (cateID <= 0) {
      return;
    }
    HttpUtils.get(
      'api/QiumiImage/squareByCategory',
      <String, dynamic>{'page': 1, 'size': 10, 'category_id': cateID},
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
        hotImagesList.clear();
        hotImagesList.addAll(beans);
        _decideType();
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
        onFail?.call(code, msg);
      },
    );
  }

  /// 视频模板列表分页（VideoFaceFusion/getTemplateList）
  void fetchHotVideos(
    int cateID, {
    Function(dynamic data)? onSuccess,
    Function(int code, String msg)? onFail,
  }) {
    if (cateID <= 0) {
      return;
    }
    HttpUtils.get(
      APIs.getTemplateList,
      <String, dynamic>{'page': 1, 'pageSize': 10, 'category_id': cateID},
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
        templateHotList.clear();
        templateHotList.addAll(beans);
        _decideType();
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
        onFail?.call(code, msg);
      },
    );
  }

  /// 图生视频、文生视频
  void generateVideo() {
    Map<String, dynamic> videoParams = {
      'optimize_prompt': 1,
      'cfg_scale': double.parse(0.5.toStringAsFixed(2)),
      'duration': 5,
      'aspect_ratio': ImageAspectRatio.ratio4_3.label.replaceAll("/", ":"),
      "mode": 'std',
      "type": 6,

      /// 普通图生视频 6， 首尾帧5， 参考视频6
    };
    final AiVideoSquareModel model = hotList[index.value];
    videoParams['prompt'] = model.prompt;
    final List<String> images = List<String>.from(
      model.multiImage ?? <String>[],
    );
    if (shouldUseUploadedImageFlow() && uploadedImageUrl.value.isNotEmpty) {
      if (images.isEmpty) {
        images.add(uploadedImageUrl.value);
      } else {
        images[0] = uploadedImageUrl.value;
      }
    }
    videoParams['images'] = images;
    videoParams['aspect_ratio'] = model.aspectRatio;
    videoParams['mode'] = model.mode;
    videoParams['cfg_scale'] = model.cfgScale;
    LoadingDialog().show(message: '创建中...');
    HttpUtils.post(
      "api/VideoAi/createAiVideoTask",
      videoParams,
      success: (data) {
        LoadingDialog().dismiss();
        Toast.showText(type: .success, text: '生成成功');
        Get.toNamed(Routes.userProfile);
        _getRights();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
        if (code == 1002 || code == 1000001) {
          openPayPageWithPreview();
        }
      },
    );
  }

  /// 模版任务创建：先上传图片，再调用 createCreativeTemplateTask。
  void generateTemplateVideo() {
    final VideoFaceFusionTemplateBean? model = currentTemplateVideoModel;
    if (model == null) {
      Toast.showText(text: '模板数据异常，请重试');
      return;
    }
    final String imageUrl = uploadedImageUrl.value;
    if (imageUrl.isEmpty) {
      Toast.showText(text: '请先选择并上传图片');
      return;
    }

    final Map<String, dynamic> params = <String, dynamic>{
      // 'mode': 'template',
      'image_url': imageUrl,
      'template_id': '${model.id}',
    };

    LoadingDialog().show(message: '创建中...');
    HttpUtils.post(
      APIs.createCreativeTemplateTask2,
      params,
      success: (data) {
        LoadingDialog().dismiss();
        Toast.showText(type: .success, text: '生成成功');
        Get.toNamed(Routes.userProfile);
        _getRights();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
        if (code == 1002 || code == 1000001) {
          openPayPageWithPreview();
        }
      },
    );
  }

  /// 文生图 / 图生图（图生图带 reference_images：底图在前、用户图在后）
  void generateImage() {
    Map<String, dynamic> imageParams = {'ratio': '4:3', 'model_id': 10047};
    final AiDrawImgDetailsBean model = hotImagesList[index.value];
    imageParams['prompt'] = model.prompt;
    imageParams['ratio'] = model.ratio;
    imageParams['model_id'] = model.modelId;
    imageParams['template_id'] = model.id;

    final int generateType =
        AiDrawImgDetailsBean.parseGenerateType(model.generateType) ?? 1;
    if (generateType == 2) {
      final String userUrl = uploadedImageUrl.value;
      if (userUrl.isEmpty) {
        Toast.showText(text: '请先选择并上传图片');
        return;
      }
      // imageParams['reference_images'] = '${model.picUrl},$userUrl';
      ///不拼接底图
      imageParams['reference_images'] = userUrl;
    }

    LoadingDialog().show(message: '创建中...');
    HttpUtils.post(
      "api/QiumiImage/create",
      imageParams,
      success: (data) {
        LoadingDialog().dismiss();
        Toast.showText(type: .success, text: '生成成功');
        Get.toNamed(
          Routes.userProfile,
          arguments: {'type': GenerateCategory.image},
        );
        _getRights();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Toast.showText(text: msg);
        if (code == 1002 || code == 1000001) {
          openPayPageWithPreview();
        }
      },
    );
  }
}
