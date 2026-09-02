
import 'dart:core' hide print; // 隐藏原始 print，避免冲突
export 'dart:core' show print; // 导出重写后的 print

// 保存原始 print 引用
final _originalPrint = print;

// 重写 print 函数
void print(Object? object) {
  final now = DateTime.now();
  final timeStr = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} "
      "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}"
      ".${_threeDigits(now.millisecond)}";
  _originalPrint("[$timeStr] $object");
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');
String _threeDigits(int n) => n.toString().padLeft(3, '0');