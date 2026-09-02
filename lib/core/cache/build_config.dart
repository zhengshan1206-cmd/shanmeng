/*
 * @Author: cold-x
 * @Date: 2025-06-04 09:23:08
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:21:57
 * @FilePath: /ling_bao/lib/core/cache/build_config.dart
 * @Description: 
 */

import '../network/channel.dart';
import 'environment.dart';
import 'environment_config.dart';

class BuildConfig {
  late final Environment environment;
  late final EnvironmentConfig config;
  late final ChannelType channelType;
  bool _lock = false;

  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  factory BuildConfig.instantiate({
    required Environment envType,
    required EnvironmentConfig envConfig,
    required ChannelType channelType,
  }) {
    if (instance._lock) return instance;

    instance.environment = envType;
    instance.config = envConfig;
    instance.channelType = channelType;
    instance._lock = true;

    return instance;
  }
}
