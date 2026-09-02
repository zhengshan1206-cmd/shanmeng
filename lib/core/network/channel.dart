/*
 * @Author: cold-x
 * @Date: 2025-07-04 10:57:28
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-15 20:26:55
 * @FilePath: /ling_bao/lib/core/network/channel.dart
 * @Description: 
 */
///渠道类型 不同项目 配置不同渠道
enum ChannelType {
  // 2572	ae61970aad4a48ca	闪梦AI-应用宝
  // 2571	b9e8f08e1da8746e	闪梦AI-百度
  // 2570	b6e1d23b410ad5ac	闪梦AI-安卓-快手-默认
  // 2569	48e2ff5d4f3904cf	闪梦AI- Android-头条-默认
  // 2568	336a96bb1c90846d	闪梦AI-荣耀
  // 2567	8641771b33d84756	闪梦AI-小米
  // 2566	cc6beb9ddaa34754	闪梦AI - vivo
  // 2565	3bfe82974c14e889	闪梦AI- OPPO
  // 2564	d0df91f522777000	闪梦AI-华为
  // 2562	8820ed84dec3c4cb	闪梦AI -默认
  // 2561	265fd7ca8b449bf9	闪梦-测试
  ///华为应用市场
  huawei('d0df91f522777000', 2564),

  ///百度默认
  baidu('b9e8f08e1da8746e', 2571),

  ///应用宝
  tencent('ae61970aad4a48ca', 2572),

  ///vivo
  vivo('cc6beb9ddaa34754', 2566),

  ///小米
  xiaomi('8641771b33d84756', 2567),

  ///oppo
  oppo('3bfe82974c14e889', 2565),

  ///快手
  kwai('b6e1d23b410ad5ac', 2570),

  ///头条
  headlines('48e2ff5d4f3904cf', 2569),

  ///荣耀
  huaweiHonor('336a96bb1c90846d', 2568),

  ///ios
  iosAppStore("81fc86dce01ddf93", 1957),

  /// 测试
  /// 7338b1b7efad88f2 闪梦AI-测试环境
  test("7338b1b7efad88f2", 2249),
  launchTest("265fd7ca8b449bf9", 2561),

  ///
  shareTest("8820ed84dec3c4cb", 2562);

  final String channel;
  final num code;

  const ChannelType(this.channel, this.code);
}
