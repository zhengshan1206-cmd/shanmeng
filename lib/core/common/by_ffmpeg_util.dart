import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ling_bao/core/ui/dialog/loading_dialog.dart';
import 'package:mime/mime.dart';
import 'package:tuple/tuple.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'dart:convert';

import '../network/apis.dart';
import '../network/http_utils.dart';
import '../ui/view/by_common_utils.dart';

enum MediaType {
  /// 视频提取
  video,

  /// 音频提取
  audio,

  /// 图片提取
  picture,

  /// 链接提取
  link,
}

extension MediaTypeEx on MediaType {
  String get rawValue {
    switch (this) {
      case MediaType.video:
        return "视频提取";
      case MediaType.audio:
        return "音频提取";
      case MediaType.picture:
        return "图片提取";
      case MediaType.link:
        return "链接提取";
    }
  }

  String get typeValue {
    switch (this) {
      case MediaType.video:
        return "video";
      case MediaType.audio:
        return "audio";
      case MediaType.picture:
        return "image";
      case MediaType.link:
        return "link";
    }
  }

  RequestType get uploadFileType {
    switch (this) {
      case MediaType.video:
        return RequestType.video;
      case MediaType.audio:
        return RequestType.audio;
      case MediaType.picture:
        return RequestType.image;
      case MediaType.link:
        return RequestType.common;
    }
  }
}

const querySts = "ffmpeg -i input_video.mp4 -q:a 0 -map a output_audio.mp3";

class UploadInfoBean {
  String ossAccessKeyId;
  String policy;
  String key;
  String url;
  String signature;
  String objectUrl;
  String coverUrl;

  UploadInfoBean({
    required this.ossAccessKeyId,
    required this.policy,
    required this.key,
    required this.url,
    required this.signature,
    required this.objectUrl,
    required this.coverUrl,
  });

  UploadInfoBean copyWith({
    String? ossAccessKeyId,
    String? policy,
    String? key,
    String? url,
    String? signature,
    String? objectUrl,
    String? coverUrl,
  }) => UploadInfoBean(
    ossAccessKeyId: ossAccessKeyId ?? this.ossAccessKeyId,
    policy: policy ?? this.policy,
    key: key ?? this.key,
    url: url ?? this.url,
    signature: signature ?? this.signature,
    objectUrl: objectUrl ?? this.objectUrl,
    coverUrl: coverUrl ?? this.coverUrl,
  );

  factory UploadInfoBean.fromRawJson(String str) =>
      UploadInfoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadInfoBean.fromJson(Map<String, dynamic> json) => UploadInfoBean(
    ossAccessKeyId: json["OSSAccessKeyId"],
    policy: json["policy"],
    key: json["key"],
    url: json["url"],
    signature: json["Signature"],
    objectUrl: json["object_url"],
    coverUrl: json["cover_url"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "OSSAccessKeyId": ossAccessKeyId,
    "policy": policy,
    "key": key,
    "url": url,
    "Signature": signature,
    "object_url": objectUrl,
    "cover_url": coverUrl,
  };
}

class ByFfmpegUtil {
  // TODO: 新增接口实现从视频中分离音频
  /// 从视频中分离出音频文件
  static void splitAudioFileFromVideo(
    File video, {
    void Function(String erro)? onErro,
    void Function(Tuple2<String, String> resTuple)? onSuccess,
  }) async {
    // await ChannelOperate.getVideoToAudioAndTxt(video.path, isOnlyAudio: true)
    //     .then((data) {
    //   onSuccess?.call(Tuple2(
    //     "",
    //     data[ChannelApi.audioLocalFilePathResult],
    //   ));
    // }).onError((e, c) {
    //   BotToast.showText(text: e.toString());
    //   onErro?.call(e.toString());
    // });
  }

  /// 获取图片上传参数
  static void loadUploadInfo({
    required MediaType type,
    bool showLoading = true,
    String suffix = "",
    String? loadingText = '上传中...',
    void Function(UploadInfoBean)? onSuccess,
    void Function()? onFailed,
  }) {
    LoadingDialog().show(message: loadingText);
    HttpUtils.get(
      APIs.imageUpladInfo,
      {"type": type.typeValue, "ext": suffix},
      showLoading: false,
      success: (data) {
        if (showLoading) {
          LoadingDialog().dismiss();
        }
        UploadInfoBean infoBean = UploadInfoBean.fromJson(data["data"]);
        onSuccess?.call(infoBean);
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  static void uploadFile({
    required UploadInfoBean infoBean,
    required String filePath,
    String? loadingText,
    bool showLoading = true,
    void Function(dynamic)? onSuccess,
    void Function()? onFailed,
    bool? dismiss,
  }) async {
    // 在方法作用域声明 mimetype，确保 catch 块可以访问
    String mimetype = "";
    String uploadPath = filePath;

    try {
      log("filePath===> $filePath");

      if (showLoading) {
        LoadingDialog().show(message: loadingText ?? "文件上传中...");
      }
      mimetype = lookupMimeType(filePath) ?? "";
      if (mimetype.startsWith("image/")) {
        uploadPath = (await ByCommonUtils.compressIfNeeded(
          File(filePath),
        )).path;
        mimetype = lookupMimeType(uploadPath) ?? mimetype;
      }

      final fileName = uploadPath.split(Platform.pathSeparator).last;

      // 构造 FormData
      MultipartFile fileData;

      if (mimetype.isNotEmpty) {
        List<String> mimetypes = mimetype.split("/");
        fileData = await MultipartFile.fromFile(
          uploadPath,
          filename: fileName,
          contentType: DioMediaType(mimetypes[0], mimetypes[1]),
        );
      } else {
        fileData = await MultipartFile.fromFile(
          uploadPath,
          filename: fileName,
          contentType: DioMediaType('audio', 'wav'),
        );
      }

      final formData = FormData.fromMap({
        "OSSAccessKeyId": infoBean.ossAccessKeyId,
        "policy": infoBean.policy,
        "Signature": infoBean.signature,
        "key": infoBean.key,
        "success_action_status": "200",
        "file": fileData,
      });

      Dio dio = Dio();
      dio.options.contentType = "multipart/form-data";
      Response response = await dio.post(infoBean.url, data: formData);

      if (response.statusCode == 200) {
        dismiss ??= true;
        if (dismiss) {
          LoadingDialog().dismiss();
        }
        onSuccess?.call(response.data);
      } else {
        LoadingDialog().dismiss();
        BotToast.showText(text: "文件上传失败,暂不支持此格式");
        onFailed?.call();
        byDebugPrint('${response.statusMessage}', tag: "文件上传失败:");
      }
    } catch (e) {
      LoadingDialog().dismiss();
      onFailed?.call();
      byDebugPrint('$e', tag: "上传过程中发生错误:");

      // 根据文件类型和错误提供更详细的提示
      if (mimetype.isEmpty) {
        // 无法识别文件类型
        mimetype = lookupMimeType(uploadPath) ?? lookupMimeType(filePath) ?? "";
      }
      if (e.toString().contains("仅压缩图片质量后仍大于10M")) {
        BotToast.showText(text: "图片压缩后仍超过10M，请重新选择图片");
      } else if (mimetype.isNotEmpty && mimetype.contains("audio")) {
        // 音频文件上传失败
        BotToast.showText(text: "音频文件上传失败，暂不支持此格式，请上传 mp3/wav 格式音频文件");
      } else {
        // 其他文件或无法识别的文件类型
        BotToast.showText(text: "文件上传失败，暂不支持此格式文件，请上传其他格式文件");
      }
    }
  }

  /// 转换视频比特率
  static Future<void> convertVideoRatio({
    required String filePath,
    void Function(dynamic)? onSuccess,
    void Function()? onFailed,
    bool showLoading = true,
  }) async {
    HttpUtils.post(
      APIs.convertVideoRatio,
      {"video_url": filePath, "scale": "1080:1920"},
      showLoading: showLoading,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call();
      },
    );
  }

  /// 音频识别进度
  static void queryAudioRecognitionTask({
    required String requestID,
    void Function(dynamic result)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.queryAudioRecognitionTask,
      {"request_id": requestID},
      showLoading: false,
      success: (data) {
        onSuccess?.call(data["data"]);
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  static Future<void> downloadFile(
    String url,
    String? fileName, {
    bool showLoading = true,
    void Function(double progress)? onProgress,
    void Function(String filePath, AssetEntity?)? onSuccess,
    void Function()? onFailed,
    bool saveToAlbum = true,
    bool deleteWhenFinished = true,
  }) async {
    if (showLoading) {
      LoadingDialog().show(message: "文件下载中...");
    }
    try {
      /// 获取应用程序的文档目录
      final directory = await getApplicationDocumentsDirectory();
      fileName ??= url.split(Platform.pathSeparator).last;
      final filePath = "${directory.path}/$fileName";
      byDebugPrint(filePath, tag: "下载目录：");

      /// 创建Dio实例
      Dio dio = Dio();

      // 下载视频
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            byDebugPrint("${progress.toStringAsFixed(0)}%", tag: "下载进度:");
            onProgress?.call(progress);
          }
        },
      );
      byDebugPrint("开始保存");
      AssetEntity? asset;
      if (saveToAlbum) {
        asset = await saveVideoToAlbum(filePath, fileName: fileName);
      }
      if (deleteWhenFinished) {
        File file = File(filePath);
        await file.delete();
      }
      byDebugPrint("成功回调");
      LoadingDialog().dismiss();
      onSuccess?.call(filePath, asset);
    } catch (e) {
      LoadingDialog().dismiss();
      byDebugPrint("$e", tag: "文件下载失败:");
      BotToast.showText(text: "文件下载失败,请稍后重试");
      onFailed?.call();
    }
  }

  static Future<void> downloadAudio(
    String url,
    String? fileName, {
    bool showLoading = true,
    void Function(double progress)? onProgress,
    void Function(String filePath, AssetEntity?)? onSuccess,
    void Function()? onFailed,
    bool saveToAlbum = true,
    bool deleteWhenFinished = true,
  }) async {
    if (showLoading) {
      LoadingDialog().show(message: "文件下载中...");
    }
    try {
      /// 获取应用程序的文档目录
      final directory = await getApplicationDocumentsDirectory();
      fileName ??= url.split(Platform.pathSeparator).last;
      final filePath = "${directory.path}/$fileName";
      byDebugPrint(filePath, tag: "下载目录：");

      /// 创建Dio实例
      Dio dio = Dio();

      // 下载视频
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            byDebugPrint("${progress.toStringAsFixed(0)}%", tag: "下载进度:");
            onProgress?.call(progress);
          }
        },
      );
      byDebugPrint("开始保存");
      AssetEntity? asset;
      if (saveToAlbum) {
        asset = await saveVideoToAlbum(filePath, fileName: fileName);
      }
      if (deleteWhenFinished) {
        File file = File(filePath);
        await file.delete();
      }
      byDebugPrint("成功回调");
      LoadingDialog().dismiss();
      onSuccess?.call(filePath, asset);
    } catch (e) {
      LoadingDialog().dismiss();
      byDebugPrint("$e", tag: "文件下载失败:");
      BotToast.showText(text: "文件下载失败,请稍后重试");
      onFailed?.call();
    }
  }

  static Future<AssetEntity?> saveVideoToAlbum(
    String filePath, {
    String? fileName,
  }) async {
    File file = File(filePath);
    final asset = await PhotoManager.editor.saveVideo(
      file,
      title: fileName ??= filePath.split(Platform.pathSeparator).last,
    );
    LoadingDialog().dismiss();
    // BotToast.showText(text: "视频已下载到相册中");
    return asset;
  }

  /// 图片识别
  static void textExtractByImage({
    required String imgUrl,
    void Function(dynamic)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.textExtract,
      {"file_url": imgUrl, "type": "Advanced"},
      showLoading: true,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 音频识别
  static void textExtractByAudio({
    required String audioUrl,
    void Function(String requestID)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.createAudioRecognitionTask,
      {"url": audioUrl},
      success: (data) {
        onSuccess?.call(data["data"]["request_id"] ?? "");
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 鉴黄
  ///[type] 鉴黄类型: 2图片 3音频 4视频
  ///[url]  url地址
  static void contentsRisk({
    int type = 2,
    required String url,
    void Function()? onSuccess,
    void Function()? onFailed,
  }) {
    Get.log("==创建了鉴黄任务==");
    LoadingDialog().show(message: '图片鉴定中...');
    HttpUtils.post(
      APIs.contentsRisk,
      showLoading: false,
      showMsgWhenFailed: false,
      {"type": type, "url": url},
      success: (data) {
        Get.log("鉴黄任务创建成功===$data");
        LoadingDialog().dismiss();
        onSuccess?.call();
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        Get.log("鉴黄任务创建失败结果===$code  msg==$msg");
        onFailed?.call();
        if (code == -1) {
          BotToast.showText(text: msg);
        } else {
          BotToast.showText(text: msg);
        }
      },
    );
  }
}
