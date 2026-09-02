// ignore_for_file: use_key_in_widget_constructors

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/view/by_widgets_util.dart';
import 'package:ling_bao/core/ui/view/muti_status_view.dart';
import 'package:ling_bao/core/ui/view/no_stretch_scroll_behavior.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:ling_bao/global/user/user.dart';
import 'package:ling_bao/global/routes/app_pages.dart';
import 'package:ling_bao/image/bean/image_category_bean.dart';
import 'package:ling_bao/profile/main/bean/ai_draw_img_details_bean.dart';
import 'package:ling_bao/profile/main/bean/ai_video_square_model.dart';
import 'package:ling_bao/core/ui/view/video/byhy_video_player_view.dart';
import 'package:ling_bao/video/main/bean/video_face_fusion_template_bean.dart';
import 'package:ling_bao/video/main/controller/home_video_controller.dart';
import '../../../core/util/util.dart';
import '../../../global/routes/routes_utils.dart';
import '../../shared/home_assets.dart';
import '../../shared/home_models.dart';
import '../../shared/home_shared_widgets.dart';
import '../bean/home_banner_bean.dart';

// bool _flushVisibilityOnVerticalScrollEnd(ScrollNotification notification) {
//   if (notification.metrics.axis == Axis.vertical &&
//       (notification is ScrollEndNotification ||
//           notification is UserScrollNotification &&
//               notification.direction == ScrollDirection.idle)) {
//     VisibilityDetectorController.instance.notifyNow();
//   }
//   return false;
// }

class VideoTabPage extends StatefulWidget {
  const VideoTabPage({
    required this.isActive,
    required this.onOpenPayment,
    required this.onOpenProfile,
    required this.onOpenSupport,
    required this.statusMessage,
  });

  final bool isActive;
  final VoidCallback onOpenPayment;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSupport;
  final String? statusMessage;
  @override
  State<VideoTabPage> createState() => _VideoTabPageState();
}

class _VideoTabPageState extends State<VideoTabPage> {
  final HomeVideoController controller = Get.find<HomeVideoController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (controller.recommendList.isNotEmpty) {
        controller.showRecommendDialog();
      } else {
        controller.fetchHotRecommend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: ImageStarField()),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    const ImageChannelBrand(),
                    const Spacer(),
                    Obx(
                      () => !Get.find<UserController>().isVip
                          ? TopUtilityButton(
                              assetPath: HomeAssets.videoTopPremium,
                              onTap: widget.onOpenPayment,
                            )
                          : Container(),
                    ),
                    const SizedBox(width: 8),
                    TopUtilityButton(
                      assetPath: HomeAssets.videoTopSupport,
                      onTap: widget.onOpenSupport,
                    ),
                    const SizedBox(width: 8),
                    TopUtilityButton(
                      buttonKey: const Key('home-video-profile-button'),
                      assetPath: HomeAssets.videoTopProfile,
                      onTap: widget.onOpenProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(
                  () => MultiStatusView(
                    currentStatus: controller.statusType.value,
                    action: () {
                      controller.fetchCategory();
                      controller.fetchBannerData();
                    },
                    child: ScrollConfiguration(
                      behavior: const NoStretchScrollBehavior(),
                      child: Obx(() {
                        final List<ImageCategoryBean> categories =
                            List<ImageCategoryBean>.of(
                              controller.videoCategories,
                              growable: false,
                            );
                        return ListView.builder(
                          key: const PageStorageKey<String>(
                            'home-video-scroll',
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                          itemCount: categories.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Obx(
                                () => controller.bannerList.isEmpty
                                    ? Container()
                                    : GridView.builder(
                                        key: const PageStorageKey<String>(
                                          'home-video-scroll',
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          8,
                                          0,
                                          24,
                                        ),
                                        clipBehavior: Clip.none,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 8,
                                              crossAxisSpacing: 8,
                                              childAspectRatio: 171 / 79,
                                            ),
                                        itemCount: controller.bannerList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                              return VideoHeroCard(
                                                data: controller
                                                    .bannerList[index],
                                                onTap: () {
                                                  RoutesUtils.bannerTap(
                                                    controller
                                                        .bannerList[index],
                                                  );
                                                },
                                              );
                                            },
                                      ),
                              );
                            }
                            final ImageCategoryBean section =
                                categories[index - 1];
                            return Obx(() {
                              final String sectionId =
                                  section.id?.toString() ?? '';
                              return Padding(
                                padding: EdgeInsets.only(bottom: 18.w),
                                child: VideoHomeCategorySection(
                                  isActive: widget.isActive,
                                  section: section,
                                  videoList:
                                      (controller.videoItems[sectionId] ?? [])
                                          .cast<VideoFaceFusionTemplateBean>(),
                                  imageList:
                                      (controller.imageItems[sectionId] ?? [])
                                          .cast<AiDrawImgDetailsBean>(),
                                ),
                              );
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// AI 视频首页：按 `getCategoryList(type=ai_video)` 分组，横滑展示分享视频 + 分享图。
class VideoHomeCategorySection extends StatelessWidget {
  const VideoHomeCategorySection({
    super.key,
    required this.isActive,
    required this.section,
    required this.videoList,
    required this.imageList,
  });

  final bool isActive;
  final ImageCategoryBean section;
  final List<VideoFaceFusionTemplateBean> videoList;
  final List<AiDrawImgDetailsBean> imageList;

  String? get _titleIconUrl {
    final String raw = (section.iconUrl ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.toLowerCase() == 'null' || raw.toLowerCase() == 'undefined') {
      return null;
    }
    final Uri? uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return raw;
  }

  bool get _hasTitleIcon => _titleIconUrl != null;

  @override
  Widget build(BuildContext context) {
    if (videoList.isEmpty && imageList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (_hasTitleIcon) ...<Widget>[
              SizedBox(
                width: 18,
                height: 18,
                child: CachedNetworkImage(
                  imageUrl: _titleIconUrl!,
                  fit: BoxFit.contain,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder: (context, url) {
                    return ByWidgetsUtil.activityIndicator(isNormal: false);
                  },
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                section.title ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Get.find<HomeVideoController>().openCategoryMore(section),
              child: Container(
                key: Key('video-home-more-${section.id}'),
                width: 26,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        // 有视频时首页只展示视频横滑；不再叠一行 squareByCategory 的图，避免与视频卡风格接近被误认为「多一条视频」。
        // 无视频时才用图片列表兜底；点「更多」进详情仍可同时看图+视频。
        if (videoList.isNotEmpty) ...<Widget>[
          SizedBox(height: 12.w),
          SizedBox(
            height: 144.w,
            child: ListView.separated(
              key: PageStorageKey<String>('video-home-list-${section.id}'),
              scrollDirection: Axis.horizontal,
              cacheExtent: 240.w,
              itemCount: videoList.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 108.w,
                  child: RepaintBoundary(
                    child: VideoStripCard(
                      data: videoList[index],
                      shouldPlay: isActive,
                      index: index,
                      onTap: () {
                        Get.toNamed(
                          Routes.caseCreate,
                          arguments: <String, dynamic>{
                            'index': index,
                            'image': <AiDrawImgDetailsBean>[],
                            'video': videoList
                                .map((e) => e.toLegacyModel())
                                .toList(),
                            'video_templates': videoList,
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ] else if (imageList.isNotEmpty) ...<Widget>[
          SizedBox(height: 12.w),
          SizedBox(
            height: 144.w,
            child: ListView.separated(
              key: PageStorageKey<String>(
                'video-home-image-list-${section.id}',
              ),
              scrollDirection: Axis.horizontal,
              cacheExtent: 240.w,
              itemCount: imageList.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 108.w,
                  child: VideoPosterCard(
                    data: imageList[index],
                    index: index,
                    width: 108.w,
                    onTap: () {
                      Get.toNamed(
                        Routes.caseCreate,
                        arguments: <String, dynamic>{
                          'index': index,
                          'image': imageList,
                          'video': <AiVideoSquareModel>[],
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ] else ...<Widget>[
          SizedBox(
            height: 144.w,
            child: ByWidgetsUtil.activityIndicator(
              color: ByColor.colorC1,
              isNormal: false,
            ),
          ),
        ],
      ],
    );
  }
}

/// 分享视频横滑卡片（封面 + 文案条）。

class VideoStripCard extends StatefulWidget {
  const VideoStripCard({
    super.key,
    required this.data,
    required this.onTap,
    this.index = 1,
    this.shouldPlay = true,
  });

  final VideoFaceFusionTemplateBean data;
  final VoidCallback onTap;
  final bool shouldPlay;
  final int? index;
  @override
  State<VideoStripCard> createState() => _VideoStripCardState();
}

class _VideoStripCardState extends State<VideoStripCard> {
  bool get _canPlayPreview {
    if (Util.isVideo(widget.data.miniPreviewVideoUrl)) {
      final String url = widget.data.previewVideoUrl.trim();
      final String lower = url.toLowerCase();
      return lower != 'null' && lower != 'undefined';
    }
    return false;
  }

  String get _displayCoverUrl {
    final String preview = widget.data.previewCoverUrl.trim();
    if (preview.isNotEmpty &&
        preview.toLowerCase() != 'null' &&
        preview.toLowerCase() != 'undefined') {
      return preview;
    }
    return widget.data.sourceCoverUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 144.w,
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _canPlayPreview
                    ? IgnorePointer(
                        child: VideoPlayerWidget(
                          key: ValueKey(
                            'video-strip-preview-${widget.data.id}',
                          ),
                          url: widget.data.miniPreviewVideoUrl,
                          coverUrl: _displayCoverUrl,
                          coverFit: BoxFit.cover,
                          videoFit: BoxFit.cover,
                          autoPlay: true,
                          mute: true,
                          userInteractive: false,
                          active: widget.shouldPlay,
                          previewVisibilityThreshold: 0.6,
                          showVideoProgress: false,
                          disableAudioTrackWhenMuted: true,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.data.miniPreviewVideoUrl.isEmpty
                            ? _displayCoverUrl
                            : widget.data.miniPreviewVideoUrl,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        placeholder: (context, url) {
                          return ByWidgetsUtil.activityIndicator(
                            isNormal: false,
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        height: 24.w,
                        color: Color(0x66090D10),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          widget.data.title,
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
      ),
    );
  }
}

/// 首页顶部大功能卡。
class VideoHeroCard extends StatelessWidget {
  const VideoHeroCard({required this.data, required this.onTap});

  final HomeBannerBean data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: Image.network(data.imgUrl ?? '').image,
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: .end,
            //   children: <Widget>[
            //     Text(
            //       data.title ?? '',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 16,
            //         fontWeight: FontWeight.w700,
            //       ),
            //     ),
            //     const SizedBox(height: 4),
            //     Text(
            //       data.description ?? '',
            //       maxLines: 1,
            //       overflow: TextOverflow.ellipsis,
            //       style: TextStyle(
            //         color: Colors.white.withValues(alpha: 0.66),
            //         fontSize: 10,
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}

/// 首页快捷操作卡。
class VideoQuickActionCard extends StatelessWidget {
  const VideoQuickActionCard({required this.data, required this.onTap});

  final VideoQuickActionData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFF1D1D20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                data.assetPath,
                width: 24,
                height: 24,
                color: Colors.white.withValues(alpha: 0.82),
              ),
              const SizedBox(height: 10),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单个视频模板卡片。
class VideoPosterCard extends StatelessWidget {
  const VideoPosterCard({
    required this.data,
    required this.onTap,
    this.index = 1,
    this.width,
  });

  final AiDrawImgDetailsBean data;
  final VoidCallback onTap;
  final double? width;
  final int? index;

  static const double _playThreshold = 0.6;

  @override
  Widget build(BuildContext context) {
    final Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('video-poster-${data.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: data.hasPreviewVideo
                      ? IgnorePointer(
                          child: VideoPlayerWidget(
                            key: ValueKey('video-poster-preview-${data.id}'),
                            url: data.normalizedPreviewVideoUrl,
                            coverUrl: data.picUrl,
                            coverFit: BoxFit.cover,
                            videoFit: BoxFit.cover,
                            autoPlay: true,
                            mute: true,
                            userInteractive: false,
                            previewVisibilityThreshold: _playThreshold,
                            showVideoProgress: false,
                            disableAudioTrackWhenMuted: true,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: data.picUrl,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          placeholder: (context, url) {
                            return ByWidgetsUtil.activityIndicator(
                              isNormal: false,
                            );
                          },
                          fit: .cover,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 28,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.38),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.10),
                        Colors.black.withValues(alpha: 0.48),
                      ],
                    ),
                  ),
                  child: Text(
                    data.displayTitle,
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
            ],
          ),
        ),
      ),
    );

    if (width == null) {
      return card;
    }
    return SizedBox(width: width, child: card);
  }
}
