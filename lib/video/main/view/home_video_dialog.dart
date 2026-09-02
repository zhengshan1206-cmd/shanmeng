import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:video_player/video_player.dart';
import '../../../core/ui/view/by_widgets_util.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../bean/recommend_simple_bean.dart';

class HomeVideoDialog extends StatefulWidget {
  const HomeVideoDialog({super.key, required this.dataList});

  final List<RecommendSimpleBean> dataList;
  @override
  State<HomeVideoDialog> createState() => _HomeVideoDialogState();
}

class _HomeVideoDialogState extends State<HomeVideoDialog> {
  final PageController _pageController = PageController();
  Map<String, CachedVideoPlayerPlus> _controllers = {};

  int _currentVideoIndex = 0;
  bool _isMuted = false;
  double _previousVolume = 1.0;
  Timer? _timer;
  bool _isPaused = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  /// 初始化播放器
  void _initControllers() async {
    for (RecommendSimpleBean bean in widget.dataList) {
      final int index = widget.dataList.indexOf(bean);
      if (bean.isVideo) {
        final url = bean.sourceVideoUrl!.isNotEmpty
            ? bean.sourceVideoUrl!
            : bean.previewVideoUrl!;
        CachedVideoPlayerPlus controller = CachedVideoPlayerPlus.networkUrl(
          Uri.parse(url),
        );

        _controllers[bean.id.toString()] = controller;
        if (index == 0) {
          await controller.initialize();
          setState(() {
            _isInitialized = true;
          });
          controller.controller.play();
        } else {
          await controller.initialize();
        }
        controller.controller.addListener(_onVideoStateChange);
      } else {
        if (index == 0) {
          _imageNextItem();
        }
      }
    }
  }

  void _onVideoStateChange() {
    final RecommendSimpleBean item = widget.dataList[_currentVideoIndex];
    if (item.isVideo) {
      final CachedVideoPlayerPlus? controller =
          _controllers[item.id.toString()];
      if (controller == null || !controller.controller.value.isInitialized) {
        return;
      }

      final Duration duration = controller.controller.value.duration;
      if (controller.controller.value.position >= duration) {
        _advanceToNextItem(controller, _currentVideoIndex + 1);
      }
    }
  }

  Future<void> _advanceToNextItem(
    CachedVideoPlayerPlus? controller,
    int nextIndex,
  ) async {
    if (controller != null) {
      await controller.controller.seekTo(Duration.zero);
      await controller.controller.pause();
    } else {
      _timer?.cancel();
      _timer = null;
    }

    setState(() {
      // 更新索引，如果已是最后一个，则循环到第一个
      _currentVideoIndex = nextIndex % widget.dataList.length;
    });
    _pageController.jumpToPage(_currentVideoIndex);
    final RecommendSimpleBean bean = widget.dataList[_currentVideoIndex];
    if (bean.isVideo) {
      final CachedVideoPlayerPlus nextController =
          _controllers[bean.id.toString()]!;
      await nextController.controller.seekTo(Duration.zero);
      await nextController.controller.play();
      if (_isMuted) {
        nextController.controller.setVolume(0.0);
      } else {
        nextController.controller.setVolume(_previousVolume);
      }
    } else {
      _imageNextItem();
    }
  }

  /// 下一步
  void _imageNextItem() {
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      _timer?.cancel();
      _timer = null;
      if (!_isPaused) {
        _advanceToNextItem(null, _currentVideoIndex + 1);
      }
    });
  }

  /// 开静音处理
  void _toggleVolume() {
    final CachedVideoPlayerPlus? controller =
        _controllers[widget.dataList[_currentVideoIndex].id.toString()];
    if (controller == null) {
      return;
    }
    if (_isMuted) {
      // 静音：保存当前音量，然后设置为0
      _previousVolume = controller.controller.value.volume;
      controller.controller.setVolume(0.0);
    } else {
      // 取消静音：恢复到之前的音量
      controller.controller.setVolume(_previousVolume);
    }
  }

  /// 暂停当前
  void _stopCurrentPlay() {
    final RecommendSimpleBean item = widget.dataList[_currentVideoIndex];
    _isPaused = true;
    if (item.isVideo) {
      final CachedVideoPlayerPlus? controller =
          _controllers[item.id.toString()];
      controller?.controller.pause();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// 重新播放
  void _resumeCurrentPlay() {
    final RecommendSimpleBean item = widget.dataList[_currentVideoIndex];
    _isPaused = false;
    if (item.isVideo) {
      final CachedVideoPlayerPlus? controller =
          _controllers[item.id.toString()];
      controller?.controller.play();
    } else {
      _imageNextItem();
    }
  }

  @override
  void dispose() {
    // 务必在dispose中移除监听器并释放控制器，防止内存泄漏
    _timer?.cancel();
    _timer = null;
    _controllers.forEach((key, value) {
      value.controller.removeListener(() {});
      value.dispose();
    });
    _controllers.clear();
    super.dispose();
  }

  /// 带波纹的付费页样式
  Widget _buildContent() {
    return Container(
      height: ByScreenUtils.screenHeight,
      alignment: .center,
      color: Color(0x89010101),
      child: Container(
        height: 462.w,
        width: 268.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.w),
          color: Color(0xFF2B2B2B),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 358.w,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PageView.builder(
                      itemCount: widget.dataList.length,
                      controller: _pageController,
                      onPageChanged: (index) {
                        if (_currentVideoIndex != index) {
                          final RecommendSimpleBean item =
                              widget.dataList[_currentVideoIndex];
                          _advanceToNextItem(
                            item.isVideo
                                ? _controllers[item.id.toString()]
                                : null,
                            index,
                          );
                        }
                      },
                      itemBuilder: (context, index) {
                        final RecommendSimpleBean item = widget.dataList[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.w),
                            topRight: Radius.circular(24.w),
                          ),
                          child:
                              item.isVideo &&
                                  _isInitialized &&
                                  _controllers[item.id.toString()]!
                                      .isInitialized
                              ? AspectRatio(
                                  aspectRatio: _controllers[item.id.toString()]!
                                      .controller
                                      .value
                                      .aspectRatio,
                                  child: FittedBox(
                                    fit: .cover,
                                    child: SizedBox(
                                      width: _controllers[item.id.toString()]!
                                          .controller
                                          .value
                                          .size
                                          .width,
                                      height: _controllers[item.id.toString()]!
                                          .controller
                                          .value
                                          .size
                                          .height,
                                      child: VideoPlayer(
                                        _controllers[item.id.toString()]!
                                            .controller,
                                      ),
                                    ),
                                  ),
                                  // : CachedNetworkImage(
                                  //     imageUrl: item.coverUrl ?? '',
                                  //     fit: .cover,
                                  //     placeholder: (context, child) {
                                  //       return ByWidgetsUtil.activityIndicator(
                                  //         isNormal: false,
                                  //       );
                                  //     },
                                  //   ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: item.coverUrl ?? '',
                                  fit: .cover,
                                  fadeInDuration: .zero,
                                  fadeOutDuration: .zero,
                                  placeholder: (context, child) {
                                    return ByWidgetsUtil.activityIndicator(
                                      isNormal: false,
                                    );
                                  },
                                ),
                        );
                      },
                    ),
                  ),

                  /// 遮罩
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 55.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: .topCenter,
                          end: .bottomCenter,
                          colors: [
                            Color(0x003B3B3B),
                            Color(0x993B3B3B),
                            Color(0xFF3B3B3B),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  /// 遮罩
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 56.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.w),
                          topRight: Radius.circular(24.w),
                        ),
                        gradient: LinearGradient(
                          begin: .topCenter,
                          end: .bottomCenter,
                          colors: [Color(0x29000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14.w,
                    child: Container(
                      height: 5.w,
                      width: 100.w,
                      alignment: .center,
                      child: Row(
                        mainAxisAlignment: .center,
                        children: List.generate(widget.dataList.length, (
                          index,
                        ) {
                          return Container(
                            width: _currentVideoIndex == index ? 14.w : 10.w,
                            height: 5.w,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.5.w),
                              color: _currentVideoIndex == index
                                  ? ByColor.colorF0
                                  : ByColor.colorF2,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        _buildCloseBtn(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isMuted = !_isMuted;
                              _toggleVolume();
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 12.w, right: 12.w),
                            child: Image.asset(
                              'assets/video/home/icon_home_sound_${_isMuted ? 'off' : 'on'}.png',
                              width: 16.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 104.w,
              decoration: BoxDecoration(
                color: Color(0xFF3B3B3B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.w),
                  bottomRight: Radius.circular(24.w),
                ),
              ),
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  ByText.text(
                    text: widget.dataList[_currentVideoIndex].title ?? '',
                    fontSize: 18.sp,
                    textColor: ByColor.colorF1,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 6.w),
                  GestureDetector(
                    onTap: () async {
                      RecommendSimpleBean bean =
                          widget.dataList[_currentVideoIndex];
                      _stopCurrentPlay();
                      await Get.toNamed(
                        Routes.caseCreate,
                        arguments: <String, dynamic>{
                          'index': 0,
                          'is_video': bean.isVideo,
                          'id': bean.categoryID,
                          'title': bean.title,
                        },
                      );
                      _resumeCurrentPlay();
                    },
                    child: Container(
                      height: 48.w,
                      margin: EdgeInsets.symmetric(horizontal: 30.w),
                      alignment: .center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: .fill,
                          image: AssetImage(
                            'assets/video/home/btn_home_recommend_bg.png',
                          ),
                        ),
                      ),
                      child: ByText.text(
                        text: '立即体验',
                        fontSize: 18.sp,
                        textColor: ByColor.colorF0,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 22.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 关闭按钮
  Widget _buildCloseBtn() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(top: 12, left: 12.w),
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                "assets/global/common/btn_close.png",
                width: 32,
                height: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
