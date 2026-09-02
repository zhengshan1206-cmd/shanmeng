/*
 * @Author: duncy
 * @Date: 2025-09-25 14:00:01
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-09-29 16:47:58
 * @FilePath: /novel_oversea/lib/core/network/file_download.dart
 * @Description: 
 */
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// 下载工具类
class FileDownloader {

  // 下载Word文件并保存
  static Future<void> downloadWordFile({
    required String url,
    required String fileName, // 例如: "document.docx"
    required Function(double) onProgress, // 进度回调
    Function(String)? done, ///完成
    Function? failed, ///失败
  }) async {
    // 检查权限
    // bool hasPermission = await _checkPermission();
    // if (!hasPermission) {
    //   throw Exception("没有存储权限，无法下载文件");
    // }

    try {
      // 获取存储目录
      Directory? directory;
      if (Platform.isAndroid) {
        // 安卓：可以保存到外部存储
        directory = await getExternalStorageDirectory();
        // 自定义路径，例如：Android/data/包名/files/Documents
        String documentsPath = "${directory?.path}/Documents";
        directory = Directory(documentsPath);
      } else if (Platform.isIOS) {
        // iOS：保存到应用沙盒的Documents目录
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception("无法获取存储目录");
      }

      // 创建目录（如果不存在）
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 完整文件路径
      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);

      // 发起请求
      final request = http.Request('GET', Uri.parse(url));

      // 发起下载请求
      final response = await http.Client().send(request);

      // 获取文件总大小
      final contentLength = response.contentLength;

      if (contentLength == null) {
        print("无法获取获取文件大小");
        return;
      }

      // 处理字节流
      final bytes = <int>[];
      int received = 0;

      // 监听字节流
      response.stream.listen(
        (List<int> chunk) {
          bytes.addAll(chunk);
          received += chunk.length;
          // 计算进度 (0.0-1.0)
          final progress = received / contentLength;
          onProgress(progress);
        },
        onDone: () async {
          // 下载完成，写入文件
          await file.writeAsBytes(bytes);
          done?.call(filePath);
        },
        onError: (error) {
          failed?.call();
        },
        cancelOnError: true,
      );
    } catch (e) {
      failed?.call();
      throw Exception("下载出错: $e");
    }
  }
}
