import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart'
    hide ImageFormat;

import '../network/apis.dart';
import '../network/http_utils.dart';
import '../service/app_permisson/byhy_permission_utils.dart';
import '../ui/dialog/loading_dialog.dart';
import '../ui/dialog/toast.dart';
import '../ui/view/by_common_utils.dart';
import '../ui/view/by_widgets_util.dart';

class ByDownloadUtil {
  static String tmpSuffix = "_bytmp_";

  static Future<String> videoCachePathFromFileName(String fileName) async {
    final directory = await getApplicationCacheDirectory();
    final filePath = "${directory.path}/videos/$fileName";
    return filePath;
  }

  static Future<String> audioCachePathFromFileName(String fileName) async {
    final directory = await getApplicationCacheDirectory();
    final filePath = "${directory.path}/audios/$fileName";
    return filePath;
  }

  static Future<String> imgCachePathFromFileName(String fileName) async {
    final directory = await getApplicationCacheDirectory();
    final filePath = "${directory.path}/imgs/$fileName.png";
    return filePath;
  }

  static Future<String> imgCacheDirectory() async {
    final directory = await getApplicationCacheDirectory();
    final filePath = "${directory.path}/videos";
    return filePath;
  }

  static String cachedThumnailPath(String videoPath) {
    final fileName = videoPath.split(Platform.pathSeparator).last;
    final dir = videoPath.replaceAll(fileName, "");
    final imgPath = "$dir${fileName.split(".").first}.png";
    return imgPath;
  }

  ///这里的目录要对ios android做区分会引起不同的异常
  static Future<String> getExternalStorageDirectoryThumbPath() async {
    Directory? directory;
    if (Platform.isIOS) {
      directory = await getApplicationCacheDirectory();
    } else if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    }
    return directory?.path ?? "";
  }

  static Widget videoCover(String currentUrl) {
    final coverCached = cachedThumnailPath(currentUrl);
    if (coverCached.isNotEmpty && File(coverCached).existsSync()) {
      return Image.file(File(coverCached), fit: BoxFit.cover);
    }
    return ByWidgetsUtil.futuerBuilderWidget(
      future: ByDownloadUtil.generateThumbnail(currentUrl),
      builder: (ctx, data) {
        return Image.file(File(data!), fit: BoxFit.cover);
      },
      waitingWidget: ByWidgetsUtil.activityIndicator(),
    );
  }

  Future<void> generateThumbnailForNetwrokVideo(String videoUrl) async {
    try {
      // 生成缩略图并保存为临时文件
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200, // 指定宽度（可选）
        quality: 75, // 压缩质量（可选）
      );

      if (uint8list != null) {
        // 将 Uint8List 转换为文件或直接显示
        File thumbnailFile = await File(
          '/path/to/thumbnail.jpg',
        ).writeAsBytes(uint8list);
        byDebugPrint('缩略图保存路径: ${thumbnailFile.path}');
      }
    } catch (e) {
      byDebugPrint('生成缩略图失败: $e');
    }
  }

  /// 生成视频的缩略图
  static Future<String?> generateThumbnail(String videoPath) async {
    // final imgPath = cachedThumnailPath(videoPath);
    final fileName = videoPath.split(Platform.pathSeparator).last;
    final dir = await getExternalStorageDirectoryThumbPath();
    final imgPath = "$dir${fileName.split(".").first}.png";
    final exists = await File(imgPath).exists();
    if (exists) {
      byDebugPrint("缓存存在，直接返回");
      return imgPath;
    }

    final path = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: dir,
      imageFormat: ImageFormat.PNG,
      maxWidth: 200, // 缩略图高度
      quality: 100,
    );
    byDebugPrint(path, tag: "$imgPath --- 生成视频的缩略图: ");
    return path;
  }

  /// [url] 文件的地址
  /// [fileName]
  static Future<void> downloadVideo(
    String url,
    String? fileName, {
    bool showLoading = true,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
    void Function(String filePath)? onSuccess,
    void Function()? onFailed,
    bool saveToAlbum = false,
    bool deleteWhenFinished = false,
  }) async {
    if (showLoading) {
      LoadingDialog().show(message: "文件下载中...");
    }
    try {
      /// 获取应用程序的文档目录
      final directory = await getApplicationCacheDirectory();
      final videosDir = Directory("${directory.path}/videos");
      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
      }
      fileName ??= url.split(Platform.pathSeparator).last;
      final filePath = "${directory.path}/videos/$fileName";
      final file = File(filePath);

      /// 如果文件已经存在，则返回改文件的 File 对象
      final existsAlready = await file.exists();
      if (existsAlready) {
        LoadingDialog().dismiss();
        onProgress?.call(100);
        onSuccess?.call(filePath);
        return;
      }

      /// 下载文件的临时路径
      final filePathTmp = "$filePath$tmpSuffix";

      /// 创建Dio实例
      Dio dio = Dio();

      /// 下载视频到临时文件
      await dio.download(
        url,
        filePathTmp,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            byDebugPrint("${progress.toStringAsFixed(0)}%", tag: "下载进度:");
            onProgress?.call(progress);
          }
        },
      );

      // byDebugPrint(response, tag: "xxxxx下载结果: ");
      File fileTmp = File(filePathTmp);
      final fileRename = await fileTmp.rename(filePath);
      final fileRenameExists = await fileRename.exists();

      LoadingDialog().dismiss();

      if (!fileRenameExists) {
        Toast.showText(text: "视频下载失败");
        return;
      }
      onSuccess?.call(filePath);
    } catch (e) {
      LoadingDialog().dismiss();
      if (e is DioException && e.type == DioExceptionType.cancel) {
        Toast.showText(text: "下载已取消");
      } else {
        Toast.showText(text: "文件下载失败");
      }

      onFailed?.call();
    }
  }

  static Future<void> downloadAudio(
    String url,
    String? fileName, {
    bool showLoading = true,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
    void Function(String filePath)? onSuccess,
    void Function()? onFailed,
    bool saveToAlbum = true,
    bool deleteWhenFinished = true,
  }) async {
    if (showLoading) {
      LoadingDialog().show(message: "文件下载中...");
    }
    try {
      /// 获取应用程序的文档目录
      ///
      // final directory = await getExternalStorageDirectory();
      // final filePath = "${directory?.path}/DCIM/flutter/audios1/${fileName}";
      fileName ??= url.split(Platform.pathSeparator).last;
      final directory = await getApplicationCacheDirectory();
      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);
      final existsAlready = await file.exists();
      if (existsAlready) {
        LoadingDialog().dismiss();
        onProgress?.call(100);
        onSuccess?.call(filePath);
        return;
      }

      /// 下载文件的临时路径
      final filePathTmp = "$filePath$tmpSuffix";

      /// 创建Dio实例
      Dio dio = Dio();

      // 下载视频
      await dio.download(
        url,
        filePathTmp,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            byDebugPrint("${progress.toStringAsFixed(0)}%", tag: "下载进度:");
            onProgress?.call(progress);
          }
        },
      );

      File fileTmp = File(filePathTmp);
      final fileRename = await fileTmp.rename(filePath);
      final fileRenameExists = await fileRename.exists();

      LoadingDialog().dismiss();
      if (!fileRenameExists) {
        Toast.showText(text: "音频下载失败");
        return;
      }
      onSuccess?.call(filePath);
    } catch (e) {
      LoadingDialog().dismiss();
      Toast.showText(text: "文件下载失败,请稍后重试");
      onFailed?.call();
    }
  }

  static Future<AssetEntity?> saveVideoToAlbum(
    String filePath, {
    String? fileName,
    bool isToast = true,
  }) async {
    LoadingDialog().show(message: '保存中...');
    try {
      File file = File(filePath);
      final exists = await file.exists();
      if (!exists) {
        if (isToast) {
          Toast.showText(text: "保存视频到相册失败");
        }
        return null;
      }
      fileName ??= filePath.split(Platform.pathSeparator).last;

      // final assetSearch = await ByAssetsUtil.getAssetEntityByName(fileName);

      // if (assetSearch != null) {
      //   if (isToast) {
      //     Toast.showText(text: "视频已存在");
      //   }
      //   return null;
      // }

      final asset = await PhotoManager.editor.saveVideo(file, title: fileName);
      if (isToast) {
        Toast.showText(text: "视频已保存到相册中");
      }
      return asset;
    } catch (_) {
      if (isToast) {
        Toast.showText(text: "保存视频到相册失败");
      }
      return null;
    } finally {
      LoadingDialog().dismiss();
    }
  }

  static Future<AssetEntity?> saveVideo2Album(
    String filePath, {
    String? fileName,
    bool isToast = false,
  }) async {
    fileName ??= filePath.split(Platform.pathSeparator).last;
    final asset = await ImageGallerySaverPlus.saveFile(filePath);
    LoadingDialog().dismiss();
    File(filePath).delete();
    if (asset != null) {
      if (isToast) {
        Toast.showText(text: "保存到相册成功");
      }
    } else {
      if (isToast) {
        Toast.showText(text: "保存到相册失败");
      }
    }
    return asset;
  }

  /// [url] 文件的地址
  /// [fileName]
  static Future<AssetEntity?> downloadImage(
    String url, {
    String? fileName,
  }) async {
    LoadingDialog().show(message: "图片下载中...");
    // 请求存储权限
    if (await Permission.storage.request().isGranted) {
      try {
        /// 获取应用程序的文档目录
        final directory = await getApplicationDocumentsDirectory();
        fileName ??= url.split(Platform.pathSeparator).last;
        final filePath = "${directory.path}/$fileName";

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
            }
          },
        );
        File file = File(filePath);
        final asset = await PhotoManager.editor.saveImageWithPath(
          filePath,
          title: fileName,
        );
        file.delete();
        LoadingDialog().dismiss();
        Toast.showText(text: "图片已保存到相册中");
        return asset;
      } catch (e) {
        LoadingDialog().dismiss();
        Toast.showText(text: "文件下载失败,请稍后重试");
        return null;
      }
    } else {
      LoadingDialog().dismiss();
      Toast.showText(text: "请现在设置中打开文件访问权限");
      return null;
    }
  }

  /// 链接提取
  static void parseShareUrl(
    String url, {
    void Function(dynamic data)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.parseShareUrl,
      {"share_url": url},
      showLoading: true,
      success: (data) {
        Toast.showText(text: data["message"]);
        onSuccess?.call(data["data"]);
      },
      fail: (code, msg) {
        Toast.showText(text: msg);
        onFailed?.call();
      },
    );
  }

  static Future<void> saveNetwrokImage(
    String imageUrl, {
    bool showLoading = true,
  }) async {
    final status = await ByPermissionUtils.photos();
    if (!status) return;
    if (showLoading) {
      LoadingDialog().show(message: "图片保存中");
    }
    // 下载图片
    var response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    // 保存到相册
    final result = await ImageGallerySaverPlus.saveImage(
      Uint8List.fromList(response.data),
      quality: 80, // 图片质量
    );

    if (showLoading) {
      LoadingDialog().dismiss();
    }
    if (result['isSuccess']) {
      Toast.showText(text: "图片已保存到相册");
    } else {
      Toast.showText(text: "图片保存失败");
    }
  }
}
