import 'dart:async';
import 'dart:io';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import '../../../../global/ui/colors.dart';
import '../../../common/event/common_event.dart';
import '../../../util/extentions.dart';
import '../audio/byhy_audio_player.dart';
import '../by_common_utils.dart';
import '../by_widgets_util.dart';

///视频播放组件
class VideoPlayerWidgetCopy extends StatefulWidget {
  final String url;
  final String? coverUrl;
  final bool autoPlay;
  final int? offset;
  final bool userInteractive;
  final bool mute;
  final double? aspectRatio;
  final Duration? maxDuration;
  final bool showFullScreenButton;
  final bool showProgressSlider;
  const VideoPlayerWidgetCopy({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.offset,
    this.userInteractive = true,
    this.coverUrl,
    this.mute = false,
    this.aspectRatio,
    this.maxDuration,
    this.showProgressSlider = false,
    this.showFullScreenButton = false,
  });

  @override
  State<VideoPlayerWidgetCopy> createState() => VideoPlayerWidgetCopyState();
}

class VideoPlayerWidgetCopyState extends State<VideoPlayerWidgetCopy>
    with WidgetsBindingObserver {
  CachedVideoPlayerPlus? _cachedVideoPlayerPlusController;
  VideoPlayerController? _localController;
  late bool isPlaying = widget.autoPlay;
  // bool _showControls = true;
  // Timer? _hideTimer;
  bool _isBuffering = false;
  bool _hasError = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  ui.Image? _thumbImage;

  void changeMuteStatus(bool status) {
    _cachedVideoPlayerPlusController?.controller.setVolume(status ? 0.0 : 1.0);
  }

  void stopPlay() {
    _localController?.pause();
    _cachedVideoPlayerPlusController?.controller.pause();
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void resumePlay() {
    _localController?.play();
    _cachedVideoPlayerPlusController?.controller.play();
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  late StreamSubscription<PauseVideoEvent> streamSubscription;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _initializeVideoController() async {
    try {
      if (widget.url.startsWith("http")) {
        _cachedVideoPlayerPlusController = CachedVideoPlayerPlus.networkUrl(
          Uri.parse(widget.url),
        );

        await _cachedVideoPlayerPlusController!.initialize();

        if (!mounted) return;

        _cachedVideoPlayerPlusController?.controller.setVolume(
          widget.mute ? 0.0 : 1,
        );

        if (widget.offset != null && widget.offset! > 0) {
          final duration =
              _cachedVideoPlayerPlusController!.controller.value.duration;
          if (duration.inSeconds > widget.offset!) {
            await _cachedVideoPlayerPlusController!.controller.seekTo(
              Duration(seconds: widget.offset!),
            );
          }
        }

        await _cachedVideoPlayerPlusController!.controller.setLooping(true);

        if (widget.maxDuration != null) {
          _cachedVideoPlayerPlusController!.controller.addListener(
            _checkDuration,
          );
        }

        if (mounted) {
          setState(() {
            _hasError = false;
            _isBuffering = false;
          });

          if (widget.autoPlay) {
            _cachedVideoPlayerPlusController?.controller.play();
          } else {
            _cachedVideoPlayerPlusController?.controller.pause();
          }
        }
      } else {
        _localController = VideoPlayerController.file(File(widget.url));
        await _localController!.initialize();

        if (!mounted) return;

        await _localController!.setLooping(true);

        if (widget.offset != null && widget.offset! > 0) {
          final duration = _localController!.value.duration;
          if (duration.inSeconds > widget.offset!) {
            await _localController!.seekTo(Duration(seconds: widget.offset!));
          }
        }

        if (widget.maxDuration != null) {
          _localController!.addListener(_checkDuration);
        }

        if (mounted) {
          setState(() {
            _hasError = false;
            _isBuffering = false;
          });

          if (widget.autoPlay) {
            _localController?.play();
          } else {
            _localController?.pause();
          }
        }
      }
    } catch (e) {
      print("视频初始化失败: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }

      if (_retryCount < maxRetries) {
        _retryCount++;
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _initializeVideoController();
          }
        });
      }
    }
  }

  void _checkDuration() {
    if (widget.maxDuration == null) return;

    if (_cachedVideoPlayerPlusController != null) {
      if (_cachedVideoPlayerPlusController!.controller.value.position >=
          widget.maxDuration!) {
        _cachedVideoPlayerPlusController!.controller.seekTo(Duration.zero);
        _cachedVideoPlayerPlusController!.controller.pause();
        setState(() {
          isPlaying = false;
        });
      }
    } else if (_localController != null) {
      if (_localController!.value.position >= widget.maxDuration!) {
        _localController!.seekTo(Duration.zero);
        _localController!.pause();
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    byDebugPrint("--------VideoPlayerWidgetState initState", tag: "播放的url:");
    _loadThumbImage();
    _initializeVideoController();

    streamSubscription = eventBus.on<PauseVideoEvent>().listen((event) {
      if (_cachedVideoPlayerPlusController != null) {
        _cachedVideoPlayerPlusController!.controller.pause();
      }
      if (_localController != null) {
        _localController!.pause();
      }
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  Future<void> _loadThumbImage() async {
    final ByteData data = await rootBundle.load(
      'assets/tutorial/slider_icon.png',
    );
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      _thumbImage = frame.image;
    });
  }

  @override
  void dispose() {
    byDebugPrint("--------VideoPlayerWidgetState dispose", tag: "播放的url:");
    if (widget.maxDuration != null) {
      _cachedVideoPlayerPlusController?.controller.removeListener(
        _checkDuration,
      );
      _localController?.removeListener(_checkDuration);
    }
    _cachedVideoPlayerPlusController?.dispose();
    _localController?.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.userInteractive == false) return;

    if (ByAudioPlayer.sharedInstance.isPlaying) {
      ByAudioPlayer.sharedInstance.pause();
    }

    if (isPlaying) {
      _cachedVideoPlayerPlusController?.controller.pause();
    } else {
      _cachedVideoPlayerPlusController?.controller.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Video failed to load.",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _retryCount = 0;
                  _hasError = false;
                });
                _initializeVideoController();
              },
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (widget.url.startsWith("http")) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Stack(
          children: [
            Container(
              alignment: .center,
              child:
                  (_cachedVideoPlayerPlusController
                          ?.controller
                          .value
                          .isInitialized ??
                      false)
                  ? AspectRatio(
                      aspectRatio:
                          widget.aspectRatio ??
                          _cachedVideoPlayerPlusController!
                              .controller
                              .value
                              .aspectRatio,
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: _cachedVideoPlayerPlusController!
                                .controller
                                .value
                                .aspectRatio,
                            child: VideoPlayer(
                              _cachedVideoPlayerPlusController!.controller,
                            ),
                          ),
                          if (_isBuffering)
                            const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ByColor.colorC1,
                                ),
                                strokeWidth: 2,
                              ),
                            ),
                          if (widget.showProgressSlider)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                color: Colors.black.withAlphaValue(0.5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      child: Row(
                                        children: [
                                          ValueListenableBuilder<
                                            VideoPlayerValue
                                          >(
                                            valueListenable:
                                                _cachedVideoPlayerPlusController!
                                                    .controller,
                                            builder: (context, value, child) {
                                              return Text(
                                                _formatDuration(value.position),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: ValueListenableBuilder<VideoPlayerValue>(
                                              valueListenable:
                                                  _cachedVideoPlayerPlusController!
                                                      .controller,
                                              builder: (context, value, child) {
                                                final position = value
                                                    .position
                                                    .inMilliseconds
                                                    .toDouble();
                                                final duration = value
                                                    .duration
                                                    .inMilliseconds
                                                    .toDouble();

                                                return SliderTheme(
                                                  data: SliderThemeData(
                                                    trackHeight: 3,
                                                    trackShape:
                                                        const _CustomSliderTrackShape(),
                                                    thumbShape:
                                                        _CustomThumbShape(
                                                          image: _thumbImage,
                                                        ),
                                                    overlayShape:
                                                        SliderComponentShape
                                                            .noOverlay,
                                                    inactiveTrackColor:
                                                        Colors.transparent,
                                                    activeTrackColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Slider(
                                                    value: position.clamp(
                                                      0,
                                                      widget
                                                              .maxDuration
                                                              ?.inMilliseconds
                                                              .toDouble() ??
                                                          duration,
                                                    ),
                                                    min: 0,
                                                    max:
                                                        widget
                                                            .maxDuration
                                                            ?.inMilliseconds
                                                            .toDouble() ??
                                                        duration,
                                                    onChanged: (newValue) {
                                                      if (widget.maxDuration !=
                                                              null &&
                                                          newValue >
                                                              widget
                                                                  .maxDuration!
                                                                  .inMilliseconds) {
                                                        return;
                                                      }
                                                      _cachedVideoPlayerPlusController
                                                          ?.controller
                                                          .seekTo(
                                                            Duration(
                                                              milliseconds:
                                                                  newValue
                                                                      .toInt(),
                                                            ),
                                                          );
                                                    },
                                                    onChangeEnd: (newValue) {
                                                      if (isPlaying) {
                                                        _cachedVideoPlayerPlusController
                                                            ?.controller
                                                            .play();
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          ValueListenableBuilder<
                                            VideoPlayerValue
                                          >(
                                            valueListenable:
                                                _cachedVideoPlayerPlusController!
                                                    .controller,
                                            builder: (context, value, child) {
                                              return Text(
                                                _formatDuration(value.duration),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : widget.coverUrl != null && widget.coverUrl!.isNotEmpty
                  ? Image.network(widget.coverUrl!)
                  : ByWidgetsUtil.activityIndicator(),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPlaying) {
          _localController?.pause();
        } else {
          _localController?.play();
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      child: Stack(
        children: [
          Container(
            child: (_localController?.value.isInitialized ?? false)
                ? AspectRatio(
                    aspectRatio: _localController!.value.aspectRatio,
                    child: VideoPlayer(_localController!),
                  )
                : widget.coverUrl != null && widget.coverUrl!.isNotEmpty
                ? Image.network(widget.coverUrl!)
                : ByWidgetsUtil.activityIndicator(),
          ),
        ],
      ),
    );
  }
}

class _CustomSliderTrackShape extends SliderTrackShape {
  const _CustomSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = 3;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final double trackHeight = 3;
    final double trackRadius = 2;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    final Rect trackRect = Rect.fromLTWH(
      trackLeft,
      trackTop,
      trackWidth,
      trackHeight,
    );

    // 底色
    final Paint inactivePaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.45)
      ..style = PaintingStyle.fill;
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(trackRadius)),
      inactivePaint,
    );

    // 已过进度渐变
    final double progress = (thumbCenter.dx - trackLeft) / trackWidth;
    if (progress > 0) {
      final Rect progressRect = Rect.fromLTWH(
        trackLeft,
        trackTop,
        trackWidth * progress,
        trackHeight,
      );
      final Paint activePaint = Paint()
        ..shader = LinearGradient(
          colors: [Color(0xFF98FC4A), Color(0xFF0BBA92), Color(0xFF0181FC)],
          stops: [0.0, 0.505, 1.0],
        ).createShader(progressRect);
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(progressRect, Radius.circular(10)),
        activePaint,
      );
    }
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double thumbRadius = 7.5;
  final ui.Image? image;
  const _CustomThumbShape({required this.image});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(thumbRadius * 2, thumbRadius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    if (image != null) {
      final Canvas canvas = context.canvas;
      final paint = Paint();
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromCenter(
          center: center,
          width: thumbRadius * 2,
          height: thumbRadius * 2,
        ),
        paint,
      );
    }
  }
}
