import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;

/// 播放器当前的状态
enum ByAudioPlayerStatus {
  /// 正在加载
  loading,

  /// 播放中
  playing,

  /// 已暂停
  pause,

  /// 已停止播放
  stop,

  /// 已恢复
  resume,

  /// 播放完毕
  complete
}

///音频播放处理工具（单例模式）
class ByAudioPlayer {
  /// 内部的播放器对象
  late final AudioPlayer _audioPlayer;
  final StreamController<ByAudioPlayerStatus> _playerStatusController =
      StreamController.broadcast();
  Stream<ByAudioPlayerStatus> audioStream() {
    return _playerStatusController.stream;
  }

  /// 私有构造函数
  ByAudioPlayer._privateConstructor() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _init();
  }

  // 单例实例
  static final ByAudioPlayer _instance = ByAudioPlayer._privateConstructor();
  StreamSubscription? _positionSubscription;

  // 提供单例实例
  static ByAudioPlayer get sharedInstance {
    return _instance;
  }

  /// 播放完成
  bool complete = false;

  /// 是否正在播放
  bool isPlaying = false;

  /// 是否已初始化
  bool initialized = false;

  /// 播放音频
  Future<bool> play(
    String url, {
    ReleaseMode releaseMode = ReleaseMode.loop,
    Duration? position,
    double playbackRate = 1.0,
    double volume = 1.0,
  }) async {
    /// 每次播放前先停止正在播放的内容
    _playerStatusController.sink.add(ByAudioPlayerStatus.playing);
    await _audioPlayer.stop();

    /// 播放的新的内容 做ios兼容
    if (Platform.isAndroid) {
      await _audioPlayer.play(
        UrlSource(url),
        position: position,
      );
    } else {
      developer.log("换一种音频文件播放形式==>$url");
      await _audioPlayer.play(
        DeviceFileSource(url),
        position: position,
      );
    }

    /// 设置播放语速
    _audioPlayer.setPlaybackRate(playbackRate);

    /// 设置播放音量
    _audioPlayer.setVolume(volume);

    if (releaseMode != _audioPlayer.releaseMode) {
      await _audioPlayer.setReleaseMode(releaseMode);
    }
    isPlaying = true;
    return isPlaying;
  }

  Future<void> seekTo(int seconds) async {
    return _audioPlayer.seek(Duration(seconds: seconds));
  }

  ///设置音频播放资源
  Future<void> setSource(String url) async {
    if (Platform.isIOS) {
      return _audioPlayer.setSourceDeviceFile(url);
    } else {
      return _audioPlayer.setSource(UrlSource(url));
    }
  }

  Future<Duration?> getDuration() async {
    return _audioPlayer.getDuration();
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  /// 监听播放状态
  Future<StreamSubscription> listener(void Function(PlayerState event)? onData) async {
    return _audioPlayer.onPlayerStateChanged.listen(onData);
  }

  /// 监听播放进度
  dynamic onPositionChanged(
    void Function(Duration event)? onData,
  ) async {
    _positionSubscription = _audioPlayer.onPositionChanged.listen(onData);
    return _positionSubscription;
  }

  /// 监听播放总进度
  Future<StreamSubscription> onDurationChanged(
    void Function(Duration event)? onData,
  ) async {
    return _audioPlayer.onDurationChanged.listen(onData);
  }

  /// 停止播放
  Future<bool> stop() async {
    _playerStatusController.sink.add(ByAudioPlayerStatus.stop);
    await _audioPlayer.stop();
    isPlaying = false;
    return isPlaying;
  }

  /// 暂停播放
  Future<bool> pause() async {
    _playerStatusController.sink.add(ByAudioPlayerStatus.pause);
    await _audioPlayer.pause();
    isPlaying = false;
    return isPlaying;
  }

  void setPlaybackRate(double playbackRate) {
    _audioPlayer.setPlaybackRate(playbackRate);
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
  }

  /// 恢复播放
  Future<bool> resume({
    double playbackRate = 1.0,
    double volume = 1.0,
  }) async {
    _playerStatusController.sink.add(ByAudioPlayerStatus.resume);
    _audioPlayer.setPlaybackRate(playbackRate);

    /// 设置播放音量
    _audioPlayer.setVolume(volume);
    await _audioPlayer.resume();
    isPlaying = true;
    return isPlaying;
  }

  /// 释放播放器资源
  Future<void> playerDispose() async {
    await stop();
    await _audioPlayer.release();
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// 初始化
  void _init() {
    if (initialized) return;

    /// 监听播放进度
    // _audioPlayer.onPositionChanged.listen(
    //   (Duration position) {
    //     final progress = position.inSeconds;
    //     if (progress == _duration) {
    //       _playerStatusController.sink.add(ByAudioPlayerStatus.complete);
    //     }
    //   },
    // );

    // // 监听音频总时长
    // _audioPlayer.onDurationChanged.listen(
    //   (Duration duration) {
    //     _duration = duration.inSeconds;
    //   },
    // );

    /// 监听播放完成事件
    _audioPlayer.onPlayerComplete.listen(
      (event) {
        _playerStatusController.sink.add(ByAudioPlayerStatus.complete);
        complete = true;
        stop();
      },
    );

    initialized = true;
  }
}
