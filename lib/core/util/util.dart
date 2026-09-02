/*
 * @Author: duncy
 * @Date: 2025-09-25 09:22:21
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-06-03 17:52:13
 * @FilePath: /ling_bao/lib/core/util/util.dart
 * @Description: 
 */
import 'dart:math';

class Util {
  // 生成 [min, max) 范围内的随机整数（不包含 max）
  static int randomInt(int min, int max) {
    if (min >= max) return min;
    return min + Random().nextInt(max - min);
  }

  static bool isGif(String url) {
    final staticExtensions = ['.webp', '.gif'];
    return staticExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  static bool isVideo(String url) {
    final staticExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.webm',
      '.wmv',
      '.flv',
      '.ogg',
    ];
    return staticExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  static bool isStaticImage(String url) {
    // 常见的静态图后缀
    final staticExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.bmp'];
    return staticExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }
}
