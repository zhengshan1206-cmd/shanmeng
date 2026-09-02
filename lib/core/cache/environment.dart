/*
 * @Author: cold-x
 * @Date: 2025-06-04 09:23:10
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:58:01
 * @FilePath: /ling_bao/lib/core/cache/environment.dart
 * @Description: 
 */

// ignore_for_file: constant_identifier_names
enum Environment {
  LOCAL('https://quickapp.zhuifengtxt.com/'),
  TEST('https://chatest.beiyinapp.com/'),
  PRODUCTION('https://inchat.beiyinapp.com/');

  final String domain;
  const Environment(this.domain);

  bool get isProduction => this == Environment.PRODUCTION;
}
