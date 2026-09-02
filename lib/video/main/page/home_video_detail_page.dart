// ignore_for_file: use_key_in_widget_constructors
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/common/event/common_event.dart';
import 'package:ling_bao/core/ui/page/base_page.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/view/no_stretch_scroll_behavior.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/video/main/bean/video_face_fusion_template_bean.dart';
import 'package:ling_bao/video/main/controller/video_create_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../core/ui/view/video/byhy_video_player_view.dart';
import '../../../core/util/util.dart';
import '../../../create/create_page.dart';
import '../../../global/routes/app_pages.dart';
import '../../../main.dart';
import '../../../profile/main/bean/ai_draw_img_details_bean.dart';
import '../../../profile/main/bean/ai_video_square_model.dart';
import '../controller/video_detail_controller.dart';
import 'home_video_page.dart';

// bool _flushDetailVisibilityOnVerticalScrollEnd(ScrollNotification notification) {
//   if (notification.metrics.axis == Axis.vertical &&
//       (notification is ScrollEndNotification ||
//           notification is UserScrollNotification &&
//               notification.direction == ScrollDirection.idle)) {
//     VisibilityDetectorController.instance.notifyNow();
//   }
//   return false;
// }

/// “查看全部”后的模板列表页。
// ignore: must_be_immutable
class VideoMorePage extends BasePage {
  @override
  VideoDetailController get controller => Get.find<VideoDetailController>();

  @override
  String get title => controller.cateTitle;

  @override
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: ScrollConfiguration(
        behavior: const NoStretchScrollBehavior(),
        child: Obx(() {
          final bool hasVid = controller.hotList.isNotEmpty;
          final bool hasImg = controller.hotImagesList.isNotEmpty;
          final VideoDetailListScope scope = controller.listScope;

          if (scope == VideoDetailListScope.video) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: ByRefresh.refresh(
                refresherKey: ValueKey('video-detail-${controller.cateID}'),
                controller: controller.videoRefreshManager.refreshController,
                enablePullUp: true,
                hideFooterWhenNotFull: false,
                onRefresh: () => controller.fetchHotVideos(true),
                onLoad: () => controller.fetchHotVideos(false),
                child: hasVid
                    ? GridView.builder(
                        key: ValueKey('video-detail-grid-${controller.cateID}'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.hotList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.67,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final VideoFaceFusionTemplateBean item =
                              controller.hotList[index];
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFF1B1B1B),
                            ),
                            child: _VideoTemplatePreviewCard(
                              item: item,
                              onTap: () {
                                Get.toNamed(
                                  Routes.caseCreate,
                                  arguments: <String, dynamic>{
                                    'index': index,
                                    'image': <AiDrawImgDetailsBean>[],
                                    'video': controller.hotList
                                        .map((e) => e.toLegacyModel())
                                        .toList(),
                                    'video_templates': controller.hotList
                                        .toList(),
                                  },
                                );
                              },
                            ),
                          );
                        },
                      )
                    : ListView(
                        key: ValueKey(
                          'video-detail-empty-${controller.cateID}',
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const <Widget>[
                          SizedBox(
                            height: 320,
                            child: _VideoDetailEmptyState(),
                          ),
                        ],
                      ),
              ),
            );
          }

          if (scope == VideoDetailListScope.both) {
            if (hasVid && hasImg) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: ByRefresh.refresh(
                  controller: controller.mixedRefreshManager.refreshController,
                  enablePullUp: true,
                  onRefresh: () => controller.refreshForMixedList(),
                  onLoad: () => controller.loadMoreForMixedList(),
                  hideFooterWhenNotFull: false,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      VideoTemplateGrid(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        items: controller.hotList.toList(),
                        onTap: (int index) {
                          Get.toNamed(
                            Routes.caseCreate,
                            arguments: <String, dynamic>{
                              'index': index,
                              'image': <AiDrawImgDetailsBean>[],
                              'video': controller.hotList
                                  .map((e) => e.toLegacyModel())
                                  .toList(),
                              'video_templates': controller.hotList.toList(),
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.hotImagesList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.67,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final AiDrawImgDetailsBean item =
                              controller.hotImagesList[index];
                          return VideoPosterCard(
                            data: item,
                            onTap: () {
                              Get.toNamed(
                                Routes.caseCreate,
                                arguments: <String, dynamic>{
                                  'index': index,
                                  'image': controller.hotImagesList.toList(),
                                  'video': <AiVideoSquareModel>[],
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          if (!hasVid && !hasImg) {
            return const Center(
              child: Text(
                '暂无内容',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: ByRefresh.refresh(
              controller: controller.refreshManager.refreshController,
              enablePullUp: true,
              onRefresh: () => controller.fetchHotImages(true),
              onLoad: () => controller.fetchHotImages(false),
              hideFooterWhenNotFull: false,
              child: GridView.builder(
                itemCount: controller.hotImagesList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.67,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final AiDrawImgDetailsBean item =
                      controller.hotImagesList[index];
                  return VideoPosterCard(
                    data: item,
                    onTap: () {
                      Get.toNamed(
                        Routes.caseCreate,
                        arguments: <String, dynamic>{
                          'index': index,
                          'image': controller.hotImagesList.toList(),
                          'video': <AiVideoSquareModel>[],
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _VideoDetailEmptyState extends StatelessWidget {
  const _VideoDetailEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '暂无内容',
        style: TextStyle(color: Colors.white38, fontSize: 14),
      ),
    );
  }
}

class _VideoTemplatePreviewCard extends StatefulWidget {
  const _VideoTemplatePreviewCard({required this.item, required this.onTap});

  final VideoFaceFusionTemplateBean item;
  final VoidCallback onTap;

  @override
  State<_VideoTemplatePreviewCard> createState() =>
      _VideoTemplatePreviewCardState();
}

class _VideoTemplatePreviewCardState extends State<_VideoTemplatePreviewCard>
    with WidgetsBindingObserver {
  static const double _playThreshold = 0.6;
  double _visibleFraction = 0;

  bool get _canPlayPreview {
    final String url = widget.item.previewVideoUrl.trim();
    if (url.isEmpty) return false;
    final String lower = url.toLowerCase();
    return lower != 'null' && lower != 'undefined';
  }

  String get _displayCoverUrl {
    final String preview = widget.item.previewCoverUrl.trim();
    if (preview.isNotEmpty &&
        preview.toLowerCase() != 'null' &&
        preview.toLowerCase() != 'undefined') {
      return preview;
    }
    return widget.item.sourceCoverUrl;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _requestVisibilityRefresh();
  }

  // @override
  // void didUpdateWidget(covariant _VideoTemplatePreviewCard oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _requestVisibilityRefresh();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     _requestVisibilityRefresh();
  //   }
  // }

  // void _requestVisibilityRefresh() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!mounted) return;
  //     VisibilityDetectorController.instance.notifyNow();
  //   });
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget preview = _canPlayPreview
        ? !Util.isVideo(widget.item.miniPreviewVideoUrl)
              ? CachedNetworkImage(
                  imageUrl: widget.item.miniPreviewVideoUrl,
                  placeholder: (context, url) {
                    return ByWidgetsUtil.activityIndicator(isNormal: false);
                  },
                  fit: BoxFit.cover,
                )
              : IgnorePointer(
                  child: VideoPlayerWidget(
                    key: ValueKey('video-detail-preview-${widget.item.id}'),
                    url: widget.item.previewVideoUrl,
                    coverUrl: _displayCoverUrl,
                    coverFit: BoxFit.cover,
                    videoFit: BoxFit.cover,
                    autoPlay: true,
                    mute: true,
                    userInteractive: false,
                    active: _visibleFraction >= _playThreshold,
                    showVideoProgress: false,
                    disableAudioTrackWhenMuted: true,
                  ),
                )
        : CachedNetworkImage(
            imageUrl: _displayCoverUrl,
            placeholder: (context, url) {
              return ByWidgetsUtil.activityIndicator(isNormal: false);
            },
            fit: BoxFit.cover,
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: VisibilityDetector(
          key: Key('video-detail-card-${widget.item.id}'),
          onVisibilityChanged: (VisibilityInfo info) {
            final double fraction = info.visibleFraction;
            if ((_visibleFraction - fraction).abs() > 0.01) {
              if (mounted) {
                setState(() {
                  _visibleFraction = fraction;
                });
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              preview,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      height: 28.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      alignment: Alignment.center,
                      child: Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoTemplateGrid extends StatefulWidget {
  const VideoTemplateGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.physics,
    this.shrinkWrap = false,
  });

  final List<VideoFaceFusionTemplateBean> items;
  final ValueChanged<int> onTap;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  State<VideoTemplateGrid> createState() => _VideoTemplateGridState();
}

class _VideoTemplateGridState extends State<VideoTemplateGrid>
    with WidgetsBindingObserver {
  static const double _playThreshold = 0.6;
  final Map<int, double> _visibleFractions = <int, double>{};
  double _gridVisibleFraction = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestVisibilityRefresh();
  }

  @override
  void didUpdateWidget(covariant VideoTemplateGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _requestVisibilityRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestVisibilityRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _canPlayPreview(VideoFaceFusionTemplateBean item) {
    final String url = item.previewVideoUrl.trim();
    if (url.isEmpty) return false;
    final String lower = url.toLowerCase();
    return lower != 'null' && lower != 'undefined';
  }

  void _requestVisibilityRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      VisibilityDetectorController.instance.notifyNow();
    });
  }

  String _displayCoverUrl(VideoFaceFusionTemplateBean item) {
    final String preview = item.previewCoverUrl.trim();
    if (preview.isNotEmpty &&
        preview.toLowerCase() != 'null' &&
        preview.toLowerCase() != 'undefined') {
      return preview;
    }
    return item.sourceCoverUrl;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-more-grid-${widget.hashCode}'),
      onVisibilityChanged: (VisibilityInfo info) {
        final double fraction = info.visibleFraction;
        if ((_gridVisibleFraction - fraction).abs() > 0.01) {
          setState(() {
            _gridVisibleFraction = fraction;
          });
        }
      },
      child: GridView.builder(
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: widget.items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.67,
        ),
        itemBuilder: (BuildContext context, int index) {
          final VideoFaceFusionTemplateBean item = widget.items[index];
          final bool shouldPlay =
              _canPlayPreview(item) &&
              _gridVisibleFraction > 0 &&
              (_visibleFractions[index] ?? 0) >= _playThreshold;
          final Widget preview = _canPlayPreview(item)
              ? IgnorePointer(
                  child: VideoPlayerWidget(
                    key: ValueKey('video-more-preview-${item.id}'),
                    url: item.previewVideoUrl,
                    coverUrl: _displayCoverUrl(item),
                    coverFit: BoxFit.cover,
                    videoFit: BoxFit.cover,
                    autoPlay: true,
                    mute: true,
                    userInteractive: false,
                    active: shouldPlay,
                    showVideoProgress: false,
                    disableAudioTrackWhenMuted: true,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: _displayCoverUrl(item),
                  placeholder: (context, url) {
                    return ByWidgetsUtil.activityIndicator(isNormal: false);
                  },
                  fit: BoxFit.cover,
                );
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VisibilityDetector(
                key: Key('video-more-item-${item.id}-$index'),
                onVisibilityChanged: (VisibilityInfo info) {
                  final double fraction = info.visibleFraction;
                  final double old = _visibleFractions[index] ?? -1;
                  if ((old - fraction).abs() > 0.01) {
                    setState(() {
                      _visibleFractions[index] = fraction;
                    });
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    preview,
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            height: 28.w,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            alignment: Alignment.center,
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 视频模板创作详情页。
///
/// 当前支持在模板之间横向切换，并进入加载页；真正的视频提交接口后续可直接挂在
/// onCreate 回调背后。
// ignore: must_be_immutable
class VideoCreatePage extends BasePage {
  @override
  String get title => '创作同款';

  @override
  VideoCreateController get controller => Get.find<VideoCreateController>();

  String get _playbackScope =>
      'video_create_page_preview_${controller.hashCode}';

  // @override
  // Widget build(BuildContext context) {
  //   // final HomeHotBean currentPoster =
  //   //     controller.itemList[controller.index.value];

  //   return Scaffold(
  //     backgroundColor: const Color(0xFF010101),
  //     body:
  //   );
  // }

  @override
  Widget buildActions(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: CurrencyBadge(
          onBeforeNavigate: () {
            eventBus.fire(PauseVideoEvent(scope: _playbackScope));
          },
          value: controller.rights.value == null
              ? '${controller.getUserIntegral()}'
              : '${controller.rights.value?.userIntegral}',
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return _VideoCreatePageBody(
      controller: controller,
      options: _buildOptions(),
      playbackScope: _playbackScope,
    );
  }

  CarouselOptions _buildOptions() {
    return CarouselOptions(
      height: 423.w,
      viewportFraction: 0.7,
      initialPage: controller.index.value,
      enableInfiniteScroll: false,
      reverse: false,
      autoPlay: false,
      enlargeCenterPage: true,
      onPageChanged: (int newIndex, CarouselPageChangedReason reason) {
        final int oldIndex = controller.index.value;
        controller.index.value = newIndex;
        // 仅在用户切换模板时清空上传地址；避免 Carousel 重复回调同索引时误清空（影响图生视频/图生图）
        if (oldIndex != newIndex) {
          controller.onTemplateIndexChanged();
        }
      },
      scrollDirection: Axis.horizontal,
    );
  }
}

class _VideoCreatePageBody extends StatefulWidget {
  const _VideoCreatePageBody({
    required this.controller,
    required this.options,
    required this.playbackScope,
  });

  final VideoCreateController controller;
  final CarouselOptions options;
  final String playbackScope;

  @override
  State<_VideoCreatePageBody> createState() => _VideoCreatePageBodyState();
}

class _VideoCreatePageBodyState extends State<_VideoCreatePageBody>
    with RouteAware {
  void _pausePreviewVideos() {
    eventBus.fire(PauseVideoEvent(scope: widget.playbackScope));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.unsubscribe(this);
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    _pausePreviewVideos();
  }

  @override
  void didPop() {
    _pausePreviewVideos();
  }

  @override
  Widget build(BuildContext context) {
    final VideoCreateController controller = widget.controller;
    return SafeArea(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 26),
          Expanded(
            child: Obx(() {
              if (controller.isVideo()) {
                final dynamic dataList = controller.isTemplateVideoMode
                    ? controller.templateHotList
                    : controller.hotList;
                return CarouselSlider(
                  items: dataList.map<Widget>((dynamic item) {
                    final int index = dataList.indexOf(item);
                    String coverUrl = '';
                    String videoUrl = '';
                    if (item is VideoFaceFusionTemplateBean) {
                      coverUrl = item.previewCoverUrl;
                      videoUrl = item.previewVideoUrl;
                    } else if (item is AiVideoSquareModel) {
                      coverUrl = item.coverUrl;
                      videoUrl = item.videoUrl;
                    }
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.w),
                        color: Color(0xFF1B1B1B),
                      ),
                      child: _VideoCreatePreviewCard(
                        coverUrl: coverUrl,
                        videoUrl: videoUrl,
                        selected: index == controller.index.value,
                        playbackScope: widget.playbackScope,
                      ),
                    );
                  }).toList(),
                  options: widget.options,
                );
              } else {
                return CarouselSlider(
                  items: controller.hotImagesList.map((item) {
                    final int index = controller.hotImagesList.indexOf(item);
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.w),
                        color: Color(0xFF1B1B1B),
                      ),
                      child: _ImageCreatePreviewCard(
                        data: item,
                        selected: index == controller.index.value,
                        playbackScope: widget.playbackScope,
                      ),
                    );
                  }).toList(),
                  options: widget.options,
                );
              }
            }),
          ),
          const SizedBox(height: 18),
          Obx(
            () => CreateFlowSubmitBar(
              enable: !controller.uploadingImage.value,
              integral: controller.integralRights(),
              showIntegral: controller.rights.value != null,
              userIntegral: controller.rights.value?.userIntegral ?? 0,
              onBeforeTap: _pausePreviewVideos,
              gotoPay: () {
                controller.openPayPageWithPreview();
              },
              onClick: () {
                controller.create();
              },
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

/// 创作详情页中部的模板预览卡。
class _ImageCreatePreviewCard extends StatelessWidget {
  const _ImageCreatePreviewCard({
    required this.data,
    required this.selected,
    required this.playbackScope,
  });

  final AiDrawImgDetailsBean data;
  final bool selected;
  final String playbackScope;

  @override
  Widget build(BuildContext context) {
    if (selected && data.hasPreviewVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.w),
        child: VideoPlayerWidget(
          key: ValueKey('active_image_preview_${data.id}'),
          url: data.normalizedPreviewVideoUrl,
          coverUrl: data.picUrl,
          eventScope: playbackScope,
          coverFit: BoxFit.cover,
          videoFit: BoxFit.cover,
          autoPlay: true,
          mute: true,
          userInteractive: false,
          showVideoProgress: false,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.w),
      child: CachedNetworkImage(
        imageUrl: data.picUrl,
        placeholder: (context, url) {
          return ByWidgetsUtil.activityIndicator(isNormal: false);
        },
        fit: .cover,
      ),
    );
  }
}

/// 创作详情页中部的模板预览卡。
class _VideoCreatePreviewCard extends StatelessWidget {
  const _VideoCreatePreviewCard({
    required this.videoUrl,
    required this.coverUrl,
    required this.selected,
    required this.playbackScope,
  });

  final String videoUrl;
  final String coverUrl;
  final bool selected;
  final String playbackScope;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.w),
        child: SizedBox.expand(
          child: CachedNetworkImage(
            imageUrl: coverUrl,
            placeholder: (context, url) {
              return ByWidgetsUtil.activityIndicator(isNormal: false);
            },
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.w),
      child: VideoPlayerWidget(
        key: ValueKey('active_$videoUrl'),
        url: videoUrl,
        coverUrl: coverUrl,
        eventScope: playbackScope,
        coverFit: BoxFit.cover,
        videoFit: BoxFit.cover,
        autoPlay: true,
        mute: false,
        showVideoProgress: false,
      ),
    );
  }
}

class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({required this.value, this.onBeforeNavigate});

  final String value;
  final VoidCallback? onBeforeNavigate;

  void _handleTap() {
    onBeforeNavigate?.call();
    Get.toNamed(Routes.creditsItemList);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: _handleTap,
            child: Image.asset(
              'assets/profile/icon_profile_credits.png',
              height: 20.w,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF5C5FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
