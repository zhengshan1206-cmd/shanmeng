/*
 * @Author: cold-x
 * @Date: 2025-07-23 11:35:19
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-23 11:53:06
 * @FilePath: /fastcreationmaster/lib/core/service/debounce.dart
 * @Description: 防抖参数
 */

import 'dart:async';
import 'dart:ui';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 1000});

  void run(VoidCallback action) {
    // 如果定时器已存在，取消它
    if (_timer == null || _timer?.isActive == false) {
      // 创建新的定时器
      _timer = Timer(Duration(milliseconds: milliseconds), cancel);
      action.call();
    }
  }
  
  // 手动取消防抖
  void cancel() {
    _timer?.cancel();
  }
}