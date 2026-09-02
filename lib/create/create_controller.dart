import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/dialog/loading_dialog.dart';
import 'package:ling_bao/core/ui/view/by_common_utils.dart';
import '../core/common/by_ffmpeg_util.dart';
import '../core/network/apis.dart';
import '../core/network/http_utils.dart';
import '../core/ui/dialog/toast.dart';
import '../global/other/illegal_words/controller/illegal_words_manager.dart';
import '../global/other/right_manager.dart';
import '../global/routes/app_pages.dart';
import '../global/user/user.dart';
import '../profile/main/bean/ai_draw_img_details_bean.dart';
import '../profile/main/bean/ai_video_square_model.dart';
import '../profile/main/page/profile_page.dart';
import 'home_create_type_dialog.dart';

enum CreateFlowType {
  imageToVideo('ai_image2_video'),
  textToVideo('ai_text2_video'),
  headTailVideo('ai_image2_video'),
  multiImageVideo('ai_image2_video'),
  aiDraw('ai_qiumi_paint'),
  aiEdit('ai_paint'),
  referenceImage('ai_qiumi_paint');

  final String rights;

  const CreateFlowType(this.rights);
}

enum ImageAspectRatio {
  ratio9_16("9/16", 9 / 16),
  ratio16_9("16/9", 16 / 9),
  ratio3_4("3/4", 3 / 4),
  ratio4_3("4/3", 4 / 3),
  ratio1_1("1/1", 1.0);

  final String label;
  final double value;

  const ImageAspectRatio(this.label, this.value);

  static ImageAspectRatio? fromString(String input) {
    return ImageAspectRatio.values.firstWhere(
      (e) => e.label == input,
      orElse: () => throw ArgumentError("Invalid aspect ratio: $input"),
    );
  }

  @override
  String toString() => label;
}

class CreateController extends GetxController {
  static const int referenceImageMaxCount = 3;
  static const int headTailImageCount = 2;
  static const int multiImageMaxCount = 3;

  CreateFlowType type = CreateFlowType.imageToVideo;
  String title = '';

  final String localImagePath = '';
  final String uploadedImageUrl = '';
  bool uploadingImage = false;

  /// 是否能创作
  RxBool canCreate = false.obs;

  /// 权益
  var rights = Rx<RightBean?>(null);
  // ai_image2_video

  /// 上传的图片列表
  RxList<String> referenceImageUrls = List<String>.filled(
    referenceImageMaxCount,
    '',
  ).obs;
  RxList<String> referenceLocalImagePaths = List<String>.filled(
    referenceImageMaxCount,
    '',
  ).obs;
  RxInt referenceUploadingIndex = (-1).obs;
  RxList<String> headTailImageUrls = List<String>.filled(
    headTailImageCount,
    '',
  ).obs;
  RxList<String> headTailLocalImagePaths = List<String>.filled(
    headTailImageCount,
    '',
  ).obs;
  RxInt headTailUploadingIndex = (-1).obs;
  RxList<String> multiImageUrls = List<String>.filled(
    multiImageMaxCount,
    '',
  ).obs;
  RxList<String> multiImageLocalPaths = List<String>.filled(
    multiImageMaxCount,
    '',
  ).obs;
  RxInt multiImageUploadingIndex = (-1).obs;

  /// 违禁词检测器
  IllegalWordsManager illegalWordsManager = IllegalWordsManager();

  /// 热门列表
  RxList<AiVideoSquareModel> hotList = <AiVideoSquareModel>[].obs;
  RxList<AiDrawImgDetailsBean> hotImagesList = <AiDrawImgDetailsBean>[].obs;

  /// 编辑控制器
  TextEditingController textController = TextEditingController();

  Map<String, dynamic> videoParams = {
    'optimize_prompt': 1,
    'cfg_scale': double.parse(0.5.toStringAsFixed(2)),
    'duration': 5,
    'aspect_ratio': ImageAspectRatio.ratio4_3.label.replaceAll("/", ":"),
    "mode": 'std',
    "type": 6,

    /// 普通图生视频 6， 首尾帧5， 参考视频6
  };

  Map<String, dynamic> imageParams = {'ratio': '4:3', 'model_id': 10047};

  @override
  void onInit() {
    final args = Get.arguments;
    if (args != null) {
      final CreateTypeEntryData entry = args['entry'] as CreateTypeEntryData;
      type = entry.flow;
      title = entry.title;
      if (type == CreateFlowType.headTailVideo) {
        title = '首尾帧';
      }
    }
    if (isVideoCreate()) {
      if (!isHeadTailVideoFlow && !isMultiImageVideoFlow) {
        loadVideos();
      }
    } else if (!isReferenceImageFlow) {
      loadHotImages();
    }
    super.onInit();
    _getRights();
  }

  /// 点击热门页
  void openHotCase(int index) {
    Get.toNamed(
      Routes.caseCreate,
      arguments: {'index': index, 'video': hotList, 'image': hotImagesList},
    );
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

  /// 用户积分
  int getUserIntegral() {
    return Get.find<UserController>().userInfoBean.value?.integral ?? 0;
  }

  /// 是否是视频制作
  bool isVideoCreate() {
    return [
      CreateFlowType.imageToVideo,
      CreateFlowType.headTailVideo,
      CreateFlowType.multiImageVideo,
      CreateFlowType.textToVideo,
    ].contains(type);
  }

  bool get isReferenceImageFlow => type == CreateFlowType.referenceImage;

  bool get isHeadTailVideoFlow => type == CreateFlowType.headTailVideo;

  bool get isMultiImageVideoFlow => type == CreateFlowType.multiImageVideo;

  bool get isDynamicVideoFlow => isHeadTailVideoFlow || isMultiImageVideoFlow;

  bool get isReferenceImageUploading => referenceUploadingIndex.value >= 0;

  bool get isHeadTailUploading => headTailUploadingIndex.value >= 0;

  bool get isMultiImageUploading => multiImageUploadingIndex.value >= 0;

  List<String> get selectedReferenceImageUrls =>
      referenceImageUrls.where((String url) => url.trim().isNotEmpty).toList();

  List<String> get selectedHeadTailImageUrls =>
      headTailImageUrls.where((String url) => url.trim().isNotEmpty).toList();

  List<String> get selectedMultiImageUrls =>
      multiImageUrls.where((String url) => url.trim().isNotEmpty).toList();

  /// 提示词变化
  void promptChanged(String prompt) {
    if (isVideoCreate()) {
      videoParams['prompt'] = prompt;
    } else {
      imageParams['prompt'] = prompt;
    }
    checkParams();
  }

  /// 图片变化
  void imageChanged(String url) {
    videoParams['images'] = url;
    checkParams();
  }

  /// 画面比例变化
  void ratioChanged(String ratio) {
    if (isVideoCreate()) {
      videoParams['aspect_ratio'] = ratio;
    } else {
      imageParams['ratio'] = ratio;
    }
    checkParams();
  }

  /// 获取权益
  void _getRights() {
    RightManager.fetchRights(
      type: type.rights,
      onSuccess: (bean) {
        rights.value = bean;
      },
    );
  }

  /// 检查是否有输入
  void checkParams({bool showToast = false}) {
    if (isMultiImageVideoFlow && selectedMultiImageUrls.isEmpty) {
      canCreate.value = false;
      if (showToast) {
        Toast.showText(text: '请至少上传1张图片');
      }
      return;
    }
    if (isHeadTailVideoFlow && selectedHeadTailImageUrls.length < 2) {
      canCreate.value = false;
      if (showToast) {
        Toast.showText(text: '请添加首帧和尾帧图片');
      }
      return;
    }
    if (isReferenceImageFlow && selectedReferenceImageUrls.isEmpty) {
      canCreate.value = false;
      if (showToast) {
        Toast.showText(text: '请上传参考图');
      }
      return;
    }
    if (videoParams['images'] == null &&
        [CreateFlowType.imageToVideo].contains(type)) {
      canCreate.value = false;
      if (showToast) {
        Toast.showText(text: '请上传图片');
      }
      return;
    }
    final String prompt = isVideoCreate()
        ? videoParams['prompt'] ?? ''
        : imageParams['prompt'] ?? '';
    if (prompt.isEmpty) {
      canCreate.value = false;
      if (showToast) {
        Toast.showText(text: '请输入提示词');
      }
      return;
    }
    canCreate.value = true;
  }

  /// 上传图片
  void uploadImage({Function(String, String)? onSuccess}) {
    _pickAndUploadImage(onSuccess: onSuccess);
  }

  void uploadReferenceImage(int slotIndex) {
    if (!isReferenceImageFlow) return;
    if (slotIndex < 0 || slotIndex >= referenceImageMaxCount) return;
    if (isReferenceImageUploading) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }
    _pickAndUploadImage(
      onUploadStart: () {
        referenceUploadingIndex.value = slotIndex;
        checkParams();
      },
      onUploadFailed: () {
        if (referenceUploadingIndex.value == slotIndex) {
          referenceUploadingIndex.value = -1;
        }
        checkParams();
      },
      onSuccess: (String url, String path) {
        referenceImageUrls[slotIndex] = url;
        referenceLocalImagePaths[slotIndex] = path;
        referenceUploadingIndex.value = -1;
        checkParams();
      },
    );
  }

  void uploadHeadTailImage(int slotIndex) {
    if (!isHeadTailVideoFlow) return;
    if (slotIndex < 0 || slotIndex >= headTailImageCount) return;
    if (isHeadTailUploading) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }
    _pickAndUploadImage(
      onUploadStart: () {
        headTailUploadingIndex.value = slotIndex;
        checkParams();
      },
      onUploadFailed: () {
        if (headTailUploadingIndex.value == slotIndex) {
          headTailUploadingIndex.value = -1;
        }
        checkParams();
      },
      onSuccess: (String url, String path) {
        headTailImageUrls[slotIndex] = url;
        headTailLocalImagePaths[slotIndex] = path;
        headTailUploadingIndex.value = -1;
        checkParams();
      },
    );
  }

  void uploadMultiImage(int slotIndex) {
    if (!isMultiImageVideoFlow) return;
    if (slotIndex < 0 || slotIndex >= multiImageMaxCount) return;
    if (isMultiImageUploading) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }
    _pickAndUploadImage(
      onUploadStart: () {
        multiImageUploadingIndex.value = slotIndex;
        checkParams();
      },
      onUploadFailed: () {
        if (multiImageUploadingIndex.value == slotIndex) {
          multiImageUploadingIndex.value = -1;
        }
        checkParams();
      },
      onSuccess: (String url, String path) {
        multiImageUrls[slotIndex] = url;
        multiImageLocalPaths[slotIndex] = path;
        multiImageUploadingIndex.value = -1;
        checkParams();
      },
    );
  }

  void removeReferenceImage(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= referenceImageMaxCount) return;
    referenceImageUrls[slotIndex] = '';
    referenceLocalImagePaths[slotIndex] = '';
    if (referenceUploadingIndex.value == slotIndex) {
      referenceUploadingIndex.value = -1;
    }
    checkParams();
  }

  void removeHeadTailImage(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= headTailImageCount) return;
    headTailImageUrls[slotIndex] = '';
    headTailLocalImagePaths[slotIndex] = '';
    if (headTailUploadingIndex.value == slotIndex) {
      headTailUploadingIndex.value = -1;
    }
    checkParams();
  }

  void removeMultiImage(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= multiImageMaxCount) return;
    multiImageUrls[slotIndex] = '';
    multiImageLocalPaths[slotIndex] = '';
    if (multiImageUploadingIndex.value == slotIndex) {
      multiImageUploadingIndex.value = -1;
    }
    checkParams();
  }

  void swapHeadTailImages() {
    if (!isHeadTailVideoFlow) return;
    if (isHeadTailUploading) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }

    final String firstUrl = headTailImageUrls[0];
    final String firstLocalPath = headTailLocalImagePaths[0];

    headTailImageUrls[0] = headTailImageUrls[1];
    headTailLocalImagePaths[0] = headTailLocalImagePaths[1];
    headTailImageUrls[1] = firstUrl;
    headTailLocalImagePaths[1] = firstLocalPath;
    checkParams();
  }

  void _pickAndUploadImage({
    Function(String, String)? onSuccess,
    VoidCallback? onUploadStart,
    VoidCallback? onUploadFailed,
  }) {
    ByCommonUtils.pickAssetsByType(
      Get.context!,
      type: .image,
      maxCount: 1,
      onSelectedCallback: (assets) async {
        if (assets.isEmpty) return;
        File? file = await assets.first.file;
        if (file == null) return;
        final String? validationError = _validateImageFile(file);
        if (validationError != null) {
          BotToast.showText(text: validationError);
          return;
        }
        onUploadStart?.call();
        ByFfmpegUtil.loadUploadInfo(
          type: MediaType.picture,
          onSuccess: (UploadInfoBean infoBean) {
            ByFfmpegUtil.uploadFile(
              infoBean: infoBean,
              filePath: file.path,
              onSuccess: (resp) {
                ///增加鉴黄逻辑
                ByFfmpegUtil.contentsRisk(
                  url: infoBean.objectUrl,
                  onSuccess: () {
                    onSuccess?.call(infoBean.objectUrl, file.path);
                  },
                  onFailed: onUploadFailed,
                );
              },
              onFailed: onUploadFailed,
            );
          },
          onFailed: onUploadFailed,
        );
      },
    );
  }

  String? _validateImageFile(File file) =>
      ByCommonUtils.validateImageFile(file);

  /// 开始生成
  void startGenerate() {
    if (isReferenceImageUploading) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }
    if (isHeadTailUploading) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }
    if (isMultiImageUploading) {
      Toast.showText(text: '图片上传中，请稍后');
      return;
    }
    checkParams(showToast: true);
    if (!canCreate.value) {
      return;
    }
    final String prompt = isVideoCreate()
        ? videoParams['prompt']
        : imageParams['prompt'];

    if (prompt.isNotEmpty) {
      /// 违禁词检测
      illegalWordsManager.detectIllegalWords(
        prompt,
        showDialog: true,
        manager: illegalWordsManager,
        onSuccess: (p0) {
          textController.text = p0;
          if (isVideoCreate()) {
            videoParams['prompt'] = p0;
          } else {
            imageParams['prompt'] = p0;
          }
        },
        noIllegalWords: () {
          if (isDynamicVideoFlow) {
            generateDynamicVideo();
          } else {
            isVideoCreate() ? generateVideo() : generateImage();
          }
        },
      );
    }
  }

  /// 首尾帧、多图融合视频
  void generateDynamicVideo() {
    final List<String> images = isHeadTailVideoFlow
        ? selectedHeadTailImageUrls
        : selectedMultiImageUrls;
    final Map<String, dynamic> params = <String, dynamic>{
      'prompt': videoParams['prompt'],
      'type': isHeadTailVideoFlow ? 5 : 6,
      'images': images,
    };

    LoadingDialog().show(message: '创建中...');
    HttpUtils.post(
      APIs.createDynamicVideoV2,
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
          Get.find<UserController>().jumpToPayPage();
        }
      },
    );
  }

  /// 图生视频、文生视频
  void generateVideo() {
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
          Get.find<UserController>().jumpToPayPage();
        }
      },
    );
  }

  /// 文生图
  void generateImage() {
    final Map<String, dynamic> params = Map<String, dynamic>.from(imageParams);
    if (isReferenceImageFlow) {
      params['reference_images'] = selectedReferenceImageUrls.join(',');
    }
    LoadingDialog().show(message: '创建中...');
    HttpUtils.post(
      "api/QiumiImage/create",
      params,
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
          Get.find<UserController>().jumpToPayPage();
        }
      },
    );
  }

  ///加载热门视频接口
  void loadVideos({
    int? code,
    int? requestType,
    int page = 1,
    int pageSize = 10,
    Function(List<AiVideoSquareModel> data)? onSuccess,
    Function()? onFailed,
  }) {
    // code = 1;
    // if (type == .textToVideo) {
    //   code = 2;
    // }
    //接口的category_id固定为4把    然后新增一个type  1文生视频 2图生视频
    requestType ??= type == CreateFlowType.textToVideo ? 1 : 2;

    HttpUtils.get(
      APIs.hotVideoList,
      {
        "page": page,
        "pageSize": pageSize,
        "category_id": 4,
        "type": requestType,
      },
      success: (data) {
        final List items = data["data"]["data"] ?? [];
        final caseBeans = List<AiVideoSquareModel>.from(
          items.map((ele) => AiVideoSquareModel.fromJson(ele)),
        );
        hotList.addAll(caseBeans);
        onSuccess?.call(caseBeans);
      },
      fail: (code, msg) {
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 加载热门图片
  void loadHotImages({
    int page = 1,
    int pageSize = 10,
    Function(List<AiDrawImgDetailsBean> data)? onSuccess,
    Function()? onFailed,
  }) {
    // QiumiImage/square
    HttpUtils.get(
      'api/QiumiImage/squareByCategory',
      {"page": page, "size": pageSize, "category_id": 137},
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        final caseBeans = List<AiDrawImgDetailsBean>.from(
          items.map((ele) => AiDrawImgDetailsBean.fromJson(ele)),
        );
        hotImagesList.addAll(caseBeans);
        onSuccess?.call(caseBeans);
      },
      fail: (code, msg) {
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  // VideoAi/getAiVideoCategoryDetail

  //   {
  // I/flutter ( 4340):  "page": 1,
  // I/flutter ( 4340):  "pageSize": 10,
  // I/flutter ( 4340):  "category_id": 2/1
  // I/flutter ( 4340): }

  /// 视频生成
  // void generateVideo() {
  //   String text = '生成';

  //   if (!checkParams()) {
  //     return;
  //   }
  //   String? aspectRatio = currentRatio;

  //   if (currentMode.value == 1) {
  //     data['image'] = selectedImg1[0].value;
  //     data['image_tail'] = selectedImg1[1].value;
  //   } else if (currentMode.value == 2) {
  //     List<String> urls = [];
  //     for (Pair<String, String> pair in selectedImg2) {
  //       if (pair.value.isNotEmpty == true) {
  //         urls.add(pair.value);
  //       }
  //     }

  //     ///多图
  //     data['images'] = urls;
  //   }
  //   debugPrint("上报数据===>${data}");

  //   // 添加违禁词检测
  //   detect(
  //     Get.context!,
  //     text,
  //     onSuccess: () {
  //       if (bandedWords.isNotEmpty) {
  //         BotToast.showText(text: "当前存在违禁词");
  //         final provider = AiCartoonProvider();
  //         provider.updateBandedWords(bandedWords.toList());
  //         provider.desc = currentPrompt.value;
  //         // provider.selectedDubbingId = sele
  //         showDialog(
  //           context: Get.context!,
  //           useSafeArea: false,
  //           barrierDismissible: true,
  //           builder: (ctx) => ChangeNotifierProvider.value(
  //             value: provider,
  //             child: const AiCartoonProhibitedWordsDailog<AiCartoonProvider>(),
  //           ),
  //         ).then((value) {
  //           // 对话框关闭后，将修改后的提示词同步回输入框
  //           Get.log("value===> $value");
  //           if (value != null) {
  //             if (value["desc"] != null) {
  //               if (type == 1) {
  //                 editingController1ForTextToVideo.text = value["desc"];
  //                 promptsTextForTextToVideo = value["desc"];
  //               } else {
  //                 editingController1ForImageToVideo.text = value["desc"];
  //                 promptsTextForImageToVideo = value["desc"];
  //               }
  //             }
  //             // update();
  //           }
  //         });
  //       } else {
  //         ///生成视频
  //         if (currentMode.value == 1 || currentMode.value == 2) {
  //           data["aspect_ratio"] = aspectRatio!.replaceAll("/", ":");

  //           ///首尾帧与多图生成视频请求接口
  //           HttpUtils.post(
  //             APIs.createFunnyVideoTask,
  //             showMsgWhenFailed: true,
  //             data,
  //             success: (data) {
  //               debugPrint("生成成功===>${data}");
  //               initIntegralVipController();
  //               ByNavRouterUtils.push(
  //                 Get.context!,
  //                 MultiProvider(
  //                   providers: [
  //                     ChangeNotifierProvider(
  //                       create: (context) => AiVideoManagementProvider(),
  //                     ),
  //                   ],
  //                   child: const AiVideoManagementPage(),
  //                 ),
  //               );
  //             },
  //             fail: (code, msg) {
  //               if (code == -1) {
  //                 BotToast.showText(text: msg);
  //               } else {
  //                 BotToast.showText(text: msg);
  //               }
  //             },
  //           );
  //         } else {
  //           ///文生视频与单图生成视频
  //           data['optimize_prompt'] = 1;
  //           data['cfg_scale'] = double.parse(0.5.toStringAsFixed(2));
  //           data['duration'] = getVideoDuration();
  //           if (type == 0) {
  //             data['images'] = [_selectedImg0[0].value];
  //             // data["aspect_ratio"] = aspectRatio!.replaceAll("/", ":");
  //           } else if (type == 1) {
  //             data['aspect_ratio'] = videoRatio.replaceAll("/", ":");
  //           }
  //           HttpUtils.post(
  //             "VideoAi/createAiVideoTask",
  //             data,
  //             success: (data) {
  //               byDebugPrint(data);
  //               initIntegralVipController();
  //               ByNavRouterUtils.push(
  //                 Get.context!,
  //                 MultiProvider(
  //                   providers: [
  //                     ChangeNotifierProvider(
  //                       create: (context) => AiVideoManagementProvider(),
  //                     ),
  //                   ],
  //                   child: const AiVideoManagementPage(),
  //                 ),
  //               );
  //               // onSuccess?.call();
  //             },
  //             fail: (code, msg) {
  //               BotToast.showText(text: msg);
  //             },
  //           );
  //         }
  //       }
  //     },
  //   );
  // }
}
