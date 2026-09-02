// 请求签名工具。
// 当前签名规则和旧项目保持一致：`timestamp + token` 后做 MD5。
import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 生成接口请求头里的 `sign` 字段。
class RequestSigner {
  static String sign({required int timestampSeconds, required String token}) {
    final source = '$timestampSeconds$token';
    return md5.convert(utf8.encode(source)).toString();
  }
}
