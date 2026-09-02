import 'base_channel.dart';
import 'by_channel_api.dart';

class ChannelOperate {
  ///初始化原生
  static Future<dynamic> initAppConfig(String appid, String channel) async {
    return await BaseChannel.instance.callNativeMethod(
      ChannelApi.init,
      params: {"appid": appid, "channel": channel},
    );
  }

  ///头条SDK回传
  static Future<dynamic> oceanengineEvent(String params) async {
    return await BaseChannel.instance.callNativeMethod(
      ChannelApi.oceanengineEvent,
      params: {"params": params},
    );
  }

  ///获取app设备信息
  static Future<dynamic> getAppDeviceInfo() async {
    return await BaseChannel.instance.callNativeMethod(
      ChannelApi.appDeviceInfo,
    );
  }
}
