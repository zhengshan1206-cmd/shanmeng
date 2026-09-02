
class ChannelApi {
  ///插件的身份id标识
  static const channelIdentifier = "com.by.ve.bridge";

  static const int channelSuccess = 200;

  //头条SDK回传
  static const String oceanengineEvent = "oceanengineEvent";
  //init
  static const String init = "appInit";
  //appDeviceInfo
  static const String appDeviceInfo = "appDeviceInfo";
  //从视频中提取音频
  static const String videoToAudio = "videoToAudio";
  //去重
  static const String comperssVideo = "comperssVideo";
  //视频编辑
  static const String videoEdit = "videoEdit";
  //录音
  static const String recordingRequest = "record";
  //擦除
  static const String cleanWatermark = "cleanWatermark";

  //视频帧图
  static String videoToImg = "videoToImg";
  // 获取音频文件的时长
  static const String   multimediaFilesDuration= "multimediaFilesDuration";
  //编辑视频返回的参数名
  static const String editResult = "edit_result";
  //视频file参数
  static const String videoLocalFilePathRequest = "videoLocalFilePathParameter";

  /// 视频文案提取失败重试次数
  static const String audioAndTxtRetryTimes = "kAudioAndTxtRetryTimes";
  //音频mp3file返回值
  static const String audioLocalFilePathResult = "audioLocalFilePathResult";
  //音频文案返回值
  static const String videoTextResult = "videoTextResult";
  //录音返回值
  static const String recordingResult = "recordingActivityResultData";
}
