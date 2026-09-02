/*
 * @Author: cold-x
 * @Date: 2025-06-12 15:40:13
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-14 09:40:44
 * @FilePath: /ling_bao/lib/core/util/clipboard.dart
 * @Description: 
 */

import 'package:flutter/services.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';

class ClipboardManager {
  static void clip(String? content) {
    Clipboard.setData(ClipboardData(text: content ?? ''));
    Toast.showText(text: "已复制到剪切板");
  }
}
