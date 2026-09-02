import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart'
    as video_platform;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:ui' as ui;

import '../../../../global/ui/colors.dart';
import '../../../common/assets_data.dart';
import '../../../common/event/common_event.dart';
import '../../../util/byhy_download_util.dart';
import '../../../util/extentions.dart';
import '../audio/byhy_audio_player.dart';
import '../by_common_utils.dart';
import '../by_widgets_util.dart';
import 'byhy_video_clip_preview.dart';
import '../../../../main.dart';

///视频播放组件
class VideoPlayerWidget extends StatefulWidget {
  static const double defaultPreviewVisibilityThreshold = 0.2;

  final String url;
  final String? coverUrl;
  final String? eventScope;
  final bool autoPlay;
  final int? offset;
  final bool userInteractive;
  final bool mute;
  final double? aspectRatio;
  final Duration? maxDuration;
  final bool showFullScreenButton;
  final bool showVideoProgress;
  final BoxFit? coverFit;
  final BoxFit? videoFit;
  final bool disableAudioTrackWhenMuted;
  final bool active;
  final double previewVisibilityThreshold;
  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.offset,
    this.userInteractive = true,
    this.coverUrl,
    this.eventScope,
    this.mute = false,
    this.aspectRatio,
    this.maxDuration,
    this.showVideoProgress = true,
    this.showFullScreenButton = false,
    this.coverFit,
    this.videoFit,
    this.disableAudioTrackWhenMuted = false,
    this.active = true,
    this.previewVisibilityThreshold = defaultPreviewVisibilityThreshold,
  });

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver, RouteAware {
  static const String _previewPlaybackProfileHeader = 'X-Byhy-Playback-Profile';
  static const String _previewPlaybackProfileValue = 'preview';
  CachedVideoPlayerPlus? _cachedVideoPlayerPlusController;
  VideoPlayerController? _localController;
  late bool isPlaying = widget.autoPlay;
  bool _wasPlayingBeforeBackground = false;
  int _initSession = 0;
  int _activationSession = 0;
  // bool _showControls = true;
  // Timer? _hideTimer;
  bool _isBuffering = false;
  bool _hasError = false;
  bool _isInitializing = false;
  bool _visibilityReady = false;
  double _visibleFraction = 1;
  bool _waitingForPreviewLease = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  late final int _previewOwnerId = _VideoPreviewControllerPool.nextOwnerId();
  _VideoPreviewLease? _previewLease;
  ModalRoute<dynamic>? _route;
  bool _shouldResumeAfterInterruption = false;
  int _playbackRecoveryRequestId = 0;
  Future<void>? _previewDeactivationFuture;

  ui.Image? _thumbImage;

  void changeMuteStatus(bool status) {
    _cachedVideoPlayerPlusController?.controller.setVolume(status ? 0.0 : 1.0);
  }

  void stopPlay() {
    _pausePlayback();
  }

  void resumePlay() {
    _resumePlayback();
  }

  late StreamSubscription<PauseVideoEvent> _pauseStreamSubscription;
  late StreamSubscription<ResumeVideoEvent> _resumeStreamSubscription;

  bool get _isNetworkVideo => widget.url.startsWith("http");

  bool get _isManagedPreview =>
      _isNetworkVideo && widget.autoPlay && !widget.userInteractive;

  bool get _useCachedNetworkController => _isNetworkVideo && !_isManagedPreview;

  Map<String, String> get _networkHttpHeaders => _isManagedPreview
      ? const <String, String>{
          _previewPlaybackProfileHeader: _previewPlaybackProfileValue,
        }
      : const <String, String>{};

  bool get _shouldActivateController {
    if (!_isManagedPreview) {
      return true;
    }
    if (!widget.active || !_visibilityReady) {
      return false;
    }
    return _visibleFraction >= widget.previewVisibilityThreshold;
  }

  bool get _isActuallyPlaying =>
      (_cachedVideoPlayerPlusController?.controller.value.isPlaying ?? false) ||
      (_localController?.value.isPlaying ?? false) ||
      isPlaying;

  bool get _shouldPlayWhenReady => _isManagedPreview
      ? widget.autoPlay
      : (isPlaying || _shouldResumeAfterInterruption);

  // void _startHideTimer() {
  //   _hideTimer?.cancel();
  //   _hideTimer = Timer(const Duration(seconds: 3), () {
  //     if (mounted) {
  //       setState(() {
  //         _showControls = false;
  //       });
  //     }
  //   });
  // }

  // void _toggleControls() {
  //   setState(() {
  //     _showControls = !_showControls;
  //   });
  //   if (_showControls) {
  //     _startHideTimer();
  //   }
  // }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildProgressSlider({
    required double position,
    required double duration,
    required ValueChanged<double> onSeek,
    VoidCallback? onSeekEnd,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        trackShape: const _CustomSliderTrackShape(),
        thumbShape: _CustomThumbShape(image: _thumbImage),
        overlayShape: SliderComponentShape.noOverlay,
        inactiveTrackColor: Colors.transparent,
        activeTrackColor: Colors.transparent,
      ),
      child: Slider(
        value: position.clamp(
          0,
          widget.maxDuration?.inMilliseconds.toDouble() ?? duration,
        ),
        min: 0,
        max: widget.maxDuration?.inMilliseconds.toDouble() ?? duration,
        onChanged: (newValue) {
          if (widget.maxDuration != null &&
              newValue > widget.maxDuration!.inMilliseconds) {
            return;
          }
          onSeek(newValue);
        },
        onChangeEnd: (_) {
          onSeekEnd?.call();
        },
      ),
    );
  }

  Widget _buildVideoContent({
    required double containerWidth,
    required double containerHeight,
    required double videoWidth,
    required double videoHeight,
    required Widget child,
  }) {
    final BoxFit? fit = widget.videoFit;
    if (fit != null) {
      return SizedBox(
        width: containerWidth,
        height: containerHeight,
        child: ClipRect(
          child: FittedBox(
            fit: fit,
            alignment: Alignment.center,
            child: SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: child,
            ),
          ),
        ),
      );
    }

    final double videoAspectRatio = videoWidth / videoHeight;
    final double containerAspectRatio = containerWidth / containerHeight;

    double adaptiveHeight;
    if (videoAspectRatio > containerAspectRatio) {
      adaptiveHeight = containerWidth / videoAspectRatio;
    } else {
      adaptiveHeight = containerHeight;
    }

    return SizedBox(
      width: containerWidth,
      height: adaptiveHeight,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(width: videoWidth, height: videoHeight, child: child),
        ),
      ),
    );
  }

  Future<void> _initializeVideoController() async {
    final int session = ++_initSession;
    _isInitializing = true;
    try {
      if (_isNetworkVideo) {
        await _disposeControllers();
        if (_useCachedNetworkController) {
          _cachedVideoPlayerPlusController = CachedVideoPlayerPlus.networkUrl(
            Uri.parse(widget.url),
          );
          await _cachedVideoPlayerPlusController!.initialize();
        } else {
          _localController = VideoPlayerController.networkUrl(
            Uri.parse(widget.url),
            httpHeaders: _networkHttpHeaders,
          );
          await _localController!.initialize();
        }

        if (!mounted || session != _initSession) {
          await _disposeControllers();
          return;
        }

        if (_useCachedNetworkController) {
          _cachedVideoPlayerPlusController?.controller.setVolume(
            widget.mute ? 0.0 : 1,
          );
        } else {
          await _localController?.setVolume(widget.mute ? 0.0 : 1);
        }

        if (widget.offset != null && widget.offset! > 0) {
          final duration = _useCachedNetworkController
              ? _cachedVideoPlayerPlusController!.controller.value.duration
              : _localController!.value.duration;
          if (duration.inSeconds > widget.offset!) {
            final Duration target = Duration(seconds: widget.offset!);
            if (_useCachedNetworkController) {
              await _cachedVideoPlayerPlusController!.controller.seekTo(target);
            } else {
              await _localController!.seekTo(target);
            }
          }
        }

        if (_useCachedNetworkController) {
          await _cachedVideoPlayerPlusController!.controller.setLooping(true);
        } else {
          await _localController!.setLooping(true);
        }

        if (widget.maxDuration != null) {
          if (_useCachedNetworkController) {
            _cachedVideoPlayerPlusController!.controller.addListener(
              _checkDuration,
            );
          } else {
            _localController!.addListener(_checkDuration);
          }
        }

        await _disableAudioTrackIfNeeded();

        final bool shouldPlayOnReady = _shouldPlayWhenReady;
        if (mounted) {
          setState(() {
            _hasError = false;
            _isBuffering = false;
          });

          if (shouldPlayOnReady) {
            if (_useCachedNetworkController) {
              _cachedVideoPlayerPlusController?.controller.play();
            } else {
              _localController?.play();
            }
            _shouldResumeAfterInterruption = false;
          } else {
            if (_useCachedNetworkController) {
              _cachedVideoPlayerPlusController?.controller.pause();
            } else {
              _localController?.pause();
            }
          }
        }
      } else {
        await _disposeControllers();
        _localController = VideoPlayerController.file(File(widget.url));
        await _localController!.initialize();

        if (!mounted || session != _initSession) {
          await _disposeControllers();
          return;
        }

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

        await _disableAudioTrackIfNeeded();

        if (mounted) {
          setState(() {
            _hasError = false;
            _isBuffering = false;
          });

          if (isPlaying) {
            _localController?.play();
          } else {
            _localController?.pause();
          }
        }
      }
    } catch (e) {
      if (!mounted || session != _initSession) {
        return;
      }
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }

      if (_retryCount < maxRetries) {
        _retryCount++;
        Future.delayed(Duration(seconds: 2), () {
          if (mounted && session == _initSession && _shouldActivateController) {
            _syncPlaybackLifecycle();
          }
        });
      }
    } finally {
      if (session == _initSession) {
        _isInitializing = false;
      }
    }
  }

  Future<void> _disposeControllers() async {
    final cached = _cachedVideoPlayerPlusController;
    final local = _localController;
    _cachedVideoPlayerPlusController = null;
    _localController = null;
    await cached?.dispose();
    await local?.dispose();
  }

  Future<void> _disableAudioTrackIfNeeded() async {
    if (!widget.disableAudioTrackWhenMuted ||
        !widget.mute ||
        !Platform.isAndroid) {
      return;
    }

    try {
      if (!video_platform.VideoPlayerPlatform.instance
          .isAudioTrackSupportAvailable()) {
        return;
      }
    } catch (_) {
      return;
    }

    try {
      if (_cachedVideoPlayerPlusController != null) {
        final dynamic cachedController = _cachedVideoPlayerPlusController!;
        final int textureId = (cachedController.textureId as int?) ?? -1;
        if (textureId >= 0) {
          await video_platform.VideoPlayerPlatform.instance.selectAudioTrack(
            textureId,
            '',
          );
          return;
        }
      }

      if (_localController != null &&
          _localController!.isAudioTrackSupportAvailable()) {
        await _localController!.selectAudioTrack('');
      }
    } catch (_) {
      // Best-effort optimization for muted previews; keep playback flow intact on failure.
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

  void _removeDurationListener() {
    if (widget.maxDuration == null) return;
    _cachedVideoPlayerPlusController?.controller.removeListener(_checkDuration);
    _localController?.removeListener(_checkDuration);
  }

  void _requestVisibilityRefresh() {
    if (!_isManagedPreview) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      VisibilityDetectorController.instance.notifyNow();
    });
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      VisibilityDetectorController.instance.notifyNow();
    });
  }

  void _schedulePlaybackRecovery() {
    final int requestId = ++_playbackRecoveryRequestId;
    _requestVisibilityRefresh();

    void restore() {
      if (!mounted || requestId != _playbackRecoveryRequestId) {
        return;
      }
      unawaited(_restorePlaybackAfterInterruption());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      restore();
    });
    Future<void>.delayed(const Duration(milliseconds: 160), restore);
  }

  Future<bool> _acquirePreviewLeaseIfNeeded(int activationSession) async {
    if (!_isManagedPreview) {
      return true;
    }
    if (_previewLease != null) {
      return true;
    }
    if (_waitingForPreviewLease) {
      return false;
    }

    _waitingForPreviewLease = true;
    final _VideoPreviewLease? lease = await _VideoPreviewControllerPool.acquire(
      _previewOwnerId,
    );
    _waitingForPreviewLease = false;

    if (lease == null) {
      return false;
    }

    if (!mounted ||
        activationSession != _activationSession ||
        !_shouldActivateController) {
      lease.release();
      return false;
    }

    _previewLease = lease;
    return true;
  }

  void _cancelPendingPreviewLease() {
    if (!_waitingForPreviewLease) {
      return;
    }
    _VideoPreviewControllerPool.cancel(_previewOwnerId);
    _waitingForPreviewLease = false;
  }

  void _releasePreviewLease() {
    if (_previewLease != null) {
      _previewLease!.release();
      _previewLease = null;
    } else {
      _cancelPendingPreviewLease();
    }
  }

  Future<void> _deactivatePreviewController({
    bool preserveResumeIntent = false,
  }) async {
    final Future<void> future = _performDeactivatePreviewController(
      preserveResumeIntent: preserveResumeIntent,
    );
    _previewDeactivationFuture = future;
    try {
      await future;
    } finally {
      if (identical(_previewDeactivationFuture, future)) {
        _previewDeactivationFuture = null;
      }
    }
  }

  Future<void> _performDeactivatePreviewController({
    bool preserveResumeIntent = false,
  }) async {
    _pausePlayback(
      updateState: false,
      preserveResumeIntent: preserveResumeIntent,
    );
    _initSession++;
    _isInitializing = false;
    _retryCount = 0;
    _removeDurationListener();
    final _VideoPreviewLease? leaseToRelease = _previewLease;
    _previewLease = null;
    final bool shouldCancelPendingLease = _waitingForPreviewLease;
    _waitingForPreviewLease = false;
    if (shouldCancelPendingLease) {
      _VideoPreviewControllerPool.cancel(_previewOwnerId);
    }
    await _disposeControllers();
    leaseToRelease?.release();
    if (!mounted) {
      _hasError = false;
      _isBuffering = false;
      return;
    }
    setState(() {
      _hasError = false;
      _isBuffering = false;
    });
  }

  Future<void> _syncPlaybackLifecycle({bool resetRetry = false}) async {
    final int activationSession = ++_activationSession;
    if (resetRetry) {
      _retryCount = 0;
    }

    if (!_shouldActivateController) {
      if (_isManagedPreview) {
        await _deactivatePreviewController();
      }
      return;
    }

    final Future<void>? pendingDeactivation = _previewDeactivationFuture;
    if (pendingDeactivation != null) {
      await pendingDeactivation;
      if (!mounted ||
          activationSession != _activationSession ||
          !_shouldActivateController) {
        return;
      }
    }

    if (_cachedVideoPlayerPlusController != null || _localController != null) {
      if (_shouldPlayWhenReady) {
        _resumePlayback(force: true);
      }
      return;
    }

    if (_isInitializing) {
      return;
    }

    final bool acquired = await _acquirePreviewLeaseIfNeeded(activationSession);
    if (!acquired ||
        !mounted ||
        activationSession != _activationSession ||
        !_shouldActivateController) {
      return;
    }

    await _initializeVideoController();
  }

  Future<void> _restorePlaybackAfterInterruption() async {
    if (!_shouldResumeAfterInterruption && !_isManagedPreview) {
      return;
    }

    if (_isManagedPreview) {
      _requestVisibilityRefresh();
      await _syncPlaybackLifecycle();
      return;
    }

    if (_cachedVideoPlayerPlusController != null || _localController != null) {
      _resumePlayback(force: true);
      return;
    }

    if (mounted) {
      setState(() {
        isPlaying = true;
      });
    } else {
      isPlaying = true;
    }
    await _syncPlaybackLifecycle();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!_isManagedPreview) {
      return;
    }
    final double fraction = info.visibleFraction;
    final bool visibilityReadyChanged = !_visibilityReady;
    if (!visibilityReadyChanged &&
        (_visibleFraction - fraction).abs() <= 0.01) {
      return;
    }
    _visibilityReady = true;
    _visibleFraction = fraction;
    _syncPlaybackLifecycle();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    byDebugPrint("--------VideoPlayerWidgetState initState", tag: "播放的url:");
    if (widget.showVideoProgress) {
      _loadThumbImage();
    }
    if (_isManagedPreview) {
      _visibleFraction = 0;
      _requestVisibilityRefresh();
    } else {
      _visibilityReady = true;
      _syncPlaybackLifecycle();
    }

    _pauseStreamSubscription = eventBus.on<PauseVideoEvent>().listen((event) {
      if (_matchesScope(event.scope)) {
        final bool shouldResume = _isActuallyPlaying;
        _pausePlayback(preserveResumeIntent: shouldResume);
        if (_isManagedPreview) {
          _deactivatePreviewController(preserveResumeIntent: shouldResume);
        }
      }
    });
    _resumeStreamSubscription = eventBus.on<ResumeVideoEvent>().listen((event) {
      if (_matchesScope(event.scope)) {
        _schedulePlaybackRecovery();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _wasPlayingBeforeBackground = _isActuallyPlaying;
      _pausePlayback(preserveResumeIntent: _wasPlayingBeforeBackground);
      return;
    }

    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _wasPlayingBeforeBackground =
          _wasPlayingBeforeBackground || _isActuallyPlaying;
      _pausePlayback(preserveResumeIntent: _wasPlayingBeforeBackground);
      if (_isManagedPreview) {
        _deactivatePreviewController(
          preserveResumeIntent: _wasPlayingBeforeBackground,
        );
      }
      return;
    }

    if (state == AppLifecycleState.resumed && _wasPlayingBeforeBackground) {
      if (_isManagedPreview) {
        _wasPlayingBeforeBackground = false;
        return;
      }
      _schedulePlaybackRecovery();
      _wasPlayingBeforeBackground = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route == null || route == _route) {
      return;
    }
    if (_route != null) {
      routeObserver.unsubscribe(this);
    }
    routeObserver.subscribe(this, route);
    _route = route;
  }

  @override
  void didPushNext() {
    final bool shouldResume = _isActuallyPlaying;
    _pausePlayback(preserveResumeIntent: shouldResume);
    if (_isManagedPreview) {
      _deactivatePreviewController(preserveResumeIntent: shouldResume);
    }
  }

  @override
  void didPopNext() {
    _requestVisibilityRefresh();
    _restorePlaybackAfterInterruption();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.offset != widget.offset ||
        oldWidget.maxDuration != widget.maxDuration ||
        oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.userInteractive != widget.userInteractive ||
        oldWidget.active != widget.active ||
        oldWidget.disableAudioTrackWhenMuted !=
            widget.disableAudioTrackWhenMuted) {
      if (_isManagedPreview && !widget.active) {
        _visibilityReady = false;
        _visibleFraction = 0;
      } else if (_isManagedPreview) {
        _requestVisibilityRefresh();
      } else if (!_isManagedPreview) {
        _visibilityReady = true;
      }
      _syncPlaybackLifecycle(resetRetry: true);
      return;
    }

    if (oldWidget.mute != widget.mute) {
      _cachedVideoPlayerPlusController?.controller.setVolume(
        widget.mute ? 0.0 : 1.0,
      );
      _localController?.setVolume(widget.mute ? 0.0 : 1.0);
    }
  }

  Future<void> _loadThumbImage() async {
    final ByteData data = await rootBundle.load(
      'assets/global/common/slider_icon.png',
    );
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() {
      _thumbImage = frame.image;
    });
  }

  @override
  void dispose() {
    byDebugPrint("--------VideoPlayerWidgetState dispose", tag: "播放的url:");
    WidgetsBinding.instance.removeObserver(this);
    if (_route != null) {
      routeObserver.unsubscribe(this);
      _route = null;
    }
    _activationSession++;
    _initSession++;
    _removeDurationListener();
    _releasePreviewLease();
    _disposeControllers();
    _pauseStreamSubscription.cancel();
    _resumeStreamSubscription.cancel();
    super.dispose();
  }

  bool _matchesScope(String? scope) {
    return scope == null || scope == widget.eventScope;
  }

  void _pausePlayback({
    bool updateState = true,
    bool preserveResumeIntent = false,
  }) {
    final bool shouldResume = _isActuallyPlaying;
    if (preserveResumeIntent) {
      _shouldResumeAfterInterruption =
          _shouldResumeAfterInterruption || shouldResume;
    } else {
      _shouldResumeAfterInterruption = false;
    }
    _localController?.pause();
    _cachedVideoPlayerPlusController?.controller.pause();
    if (mounted && updateState) {
      setState(() {
        isPlaying = false;
      });
      return;
    }
    isPlaying = false;
  }

  void _resumePlayback({bool force = false}) {
    if (!widget.autoPlay && !force) return;
    _localController?.play();
    _cachedVideoPlayerPlusController?.controller.play();
    _shouldResumeAfterInterruption = false;
    if (mounted) {
      setState(() {
        isPlaying = true;
      });
      return;
    }
    isPlaying = true;
  }

  void _handleTap() {
    if (widget.userInteractive == false) return;

    if (ByAudioPlayer.sharedInstance.isPlaying) {
      ByAudioPlayer.sharedInstance.pause();
    }

    if (isPlaying) {
      _pausePlayback();
    } else {
      _shouldResumeAfterInterruption = false;
      _resumePlayback(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_hasError) {
      child = const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ByColor.colorC1),
          strokeWidth: 2,
        ),
      );
    } else if (_isNetworkVideo) {
      final bool isNetworkInitialized =
          (_useCachedNetworkController &&
              (_cachedVideoPlayerPlusController?.isInitialized ?? false)) ||
          (!_useCachedNetworkController &&
              (_localController?.value.isInitialized ?? false));
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Stack(
          children: [
            isNetworkInitialized
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final maxHeight = constraints.maxHeight;
                      final maxWidth = constraints.maxWidth;
                      final double videoWidth = _useCachedNetworkController
                          ? _cachedVideoPlayerPlusController!
                                .controller
                                .value
                                .size
                                .width
                          : _localController!.value.size.width;
                      final double videoHeight = _useCachedNetworkController
                          ? _cachedVideoPlayerPlusController!
                                .controller
                                .value
                                .size
                                .height
                          : _localController!.value.size.height;
                      return Stack(
                        children: [
                          _buildVideoContent(
                            containerWidth: maxWidth,
                            containerHeight: maxHeight,
                            videoWidth: videoWidth,
                            videoHeight: videoHeight,
                            child: _useCachedNetworkController
                                ? VideoPlayer(
                                    _cachedVideoPlayerPlusController!
                                        .controller,
                                  )
                                : VideoPlayer(_localController!),
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
                          if (widget.showVideoProgress)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                width: double.infinity,
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
                                          _useCachedNetworkController
                                              ? ValueListenableBuilder<
                                                  VideoPlayerValue
                                                >(
                                                  valueListenable:
                                                      _cachedVideoPlayerPlusController!
                                                          .controller,
                                                  builder:
                                                      (context, value, child) {
                                                        return Text(
                                                          _formatDuration(
                                                            value.position,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        );
                                                      },
                                                )
                                              : ValueListenableBuilder<
                                                  VideoPlayerValue
                                                >(
                                                  valueListenable:
                                                      _localController!,
                                                  builder:
                                                      (context, value, child) {
                                                        return Text(
                                                          _formatDuration(
                                                            value.position,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        );
                                                      },
                                                ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: _useCachedNetworkController
                                                ? ValueListenableBuilder<
                                                    VideoPlayerValue
                                                  >(
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

                                                      return _buildProgressSlider(
                                                        position: position,
                                                        duration: duration,
                                                        onSeek: (newValue) =>
                                                            _cachedVideoPlayerPlusController
                                                                ?.controller
                                                                .seekTo(
                                                                  Duration(
                                                                    milliseconds:
                                                                        newValue
                                                                            .toInt(),
                                                                  ),
                                                                ),
                                                        onSeekEnd: isPlaying
                                                            ? () => _cachedVideoPlayerPlusController
                                                                  ?.controller
                                                                  .play()
                                                            : null,
                                                      );
                                                    },
                                                  )
                                                : ValueListenableBuilder<
                                                    VideoPlayerValue
                                                  >(
                                                    valueListenable:
                                                        _localController!,
                                                    builder: (context, value, child) {
                                                      final position = value
                                                          .position
                                                          .inMilliseconds
                                                          .toDouble();
                                                      final duration = value
                                                          .duration
                                                          .inMilliseconds
                                                          .toDouble();

                                                      return _buildProgressSlider(
                                                        position: position,
                                                        duration: duration,
                                                        onSeek: (newValue) =>
                                                            _localController?.seekTo(
                                                              Duration(
                                                                milliseconds:
                                                                    newValue
                                                                        .toInt(),
                                                              ),
                                                            ),
                                                        onSeekEnd: isPlaying
                                                            ? () =>
                                                                  _localController
                                                                      ?.play()
                                                            : null,
                                                      );
                                                    },
                                                  ),
                                          ),
                                          SizedBox(width: 10.w),
                                          _useCachedNetworkController
                                              ? ValueListenableBuilder<
                                                  VideoPlayerValue
                                                >(
                                                  valueListenable:
                                                      _cachedVideoPlayerPlusController!
                                                          .controller,
                                                  builder:
                                                      (context, value, child) {
                                                        return Text(
                                                          _formatDuration(
                                                            value.duration,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        );
                                                      },
                                                )
                                              : ValueListenableBuilder<
                                                  VideoPlayerValue
                                                >(
                                                  valueListenable:
                                                      _localController!,
                                                  builder:
                                                      (context, value, child) {
                                                        return Text(
                                                          _formatDuration(
                                                            value.duration,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        );
                                                      },
                                                ),
                                          widget.showFullScreenButton
                                              ? GestureDetector(
                                                  onTap: () {
                                                    if (widget.url.startsWith(
                                                      "http",
                                                    )) {
                                                      _cachedVideoPlayerPlusController
                                                          ?.controller
                                                          .pause();
                                                    } else {
                                                      _localController?.pause();
                                                    }
                                                    setState(() {
                                                      isPlaying = false;
                                                    });

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            VideoClipPreview(
                                                              widget.url,
                                                              maxDuration: widget
                                                                  .maxDuration,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 10.w,
                                                          vertical: 5.h,
                                                        ),
                                                    child: Image.asset(
                                                      "assets/tutorial/home_full_icon.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(width: 12.w),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )
                : widget.coverUrl != null
                ? SizedBox.expand(
                    child: CachedNetworkImage(
                      imageUrl: widget.coverUrl!,
                      fit: widget.coverFit,
                      placeholder: (context, url) {
                        return ByWidgetsUtil.activityIndicator(
                          isNormal: false,
                          color: ByColor.colorC1,
                        );
                      },
                      fadeInDuration: const Duration(milliseconds: 200),
                      fadeOutDuration: const Duration(milliseconds: 200),
                    ),
                  )
                : ByWidgetsUtil.activityIndicator(
                    isNormal: false,
                    color: ByColor.colorC1,
                  ),
            Positioned.fill(
              child: Offstage(
                offstage: isPlaying || !widget.userInteractive,
                child: Center(
                  child: Image.asset(
                    AssetsData.iconVideoPlay,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      child = GestureDetector(
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
            (_localController?.value.isInitialized ?? false)
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final maxHeight = constraints.maxHeight;
                      final maxWidth = constraints.maxWidth;

                      return _buildVideoContent(
                        containerWidth: maxWidth,
                        containerHeight: maxHeight,
                        videoWidth: _localController!.value.size.width,
                        videoHeight: _localController!.value.size.height,
                        child: VideoPlayer(_localController!),
                      );
                    },
                  )
                : ByDownloadUtil.videoCover(widget.url),
            Positioned.fill(
              child: Offstage(
                offstage:
                    isPlaying ||
                    (_localController?.value.isInitialized == false) ||
                    !widget.userInteractive,
                child: Center(
                  child: Image.asset(
                    AssetsData.iconVideoPlay,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_isManagedPreview) {
      return VisibilityDetector(
        key: Key('video-player-preview-$_previewOwnerId-$widget.url'),
        onVisibilityChanged: _handleVisibilityChanged,
        child: child,
      );
    }

    return child;
  }
}

class _VideoPreviewControllerPool {
  static const int maxActivePreviews = 9;
  static final Set<int> _activeOwners = <int>{};
  static final Queue<_VideoPreviewLeaseRequest> _pendingRequests =
      Queue<_VideoPreviewLeaseRequest>();
  static int _ownerSeed = 0;

  static int nextOwnerId() => ++_ownerSeed;

  static Future<_VideoPreviewLease?> acquire(int ownerId) {
    if (_activeOwners.contains(ownerId)) {
      return Future<_VideoPreviewLease?>.value(_VideoPreviewLease(ownerId));
    }

    if (_activeOwners.length < maxActivePreviews) {
      _activeOwners.add(ownerId);
      return Future<_VideoPreviewLease?>.value(_VideoPreviewLease(ownerId));
    }

    final Completer<_VideoPreviewLease?> completer =
        Completer<_VideoPreviewLease?>();
    _pendingRequests.addLast(
      _VideoPreviewLeaseRequest(ownerId: ownerId, completer: completer),
    );
    return completer.future;
  }

  static void cancel(int ownerId) {
    _pendingRequests.removeWhere((_VideoPreviewLeaseRequest request) {
      if (request.ownerId != ownerId) {
        return false;
      }
      if (!request.completer.isCompleted) {
        request.completer.complete(null);
      }
      return true;
    });
  }

  static void release(int ownerId) {
    final bool removed = _activeOwners.remove(ownerId);
    if (!removed) {
      cancel(ownerId);
      return;
    }
    _drainQueue();
  }

  static void _drainQueue() {
    while (_activeOwners.length < maxActivePreviews &&
        _pendingRequests.isNotEmpty) {
      final _VideoPreviewLeaseRequest request = _pendingRequests.removeFirst();
      if (request.completer.isCompleted) {
        continue;
      }
      _activeOwners.add(request.ownerId);
      request.completer.complete(_VideoPreviewLease(request.ownerId));
    }
  }
}

class _VideoPreviewLeaseRequest {
  const _VideoPreviewLeaseRequest({
    required this.ownerId,
    required this.completer,
  });

  final int ownerId;
  final Completer<_VideoPreviewLease?> completer;
}

class _VideoPreviewLease {
  const _VideoPreviewLease(this.ownerId);

  final int ownerId;

  void release() {
    _VideoPreviewControllerPool.release(ownerId);
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
        ..shader = const LinearGradient(
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
