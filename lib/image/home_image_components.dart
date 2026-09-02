// ignore_for_file: use_key_in_widget_constructors
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ling_bao/core/ui/view/video/byhy_video_player_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../core/ui/view/by_widgets_util.dart';
import 'bean/image_category_bean.dart';
import '../profile/main/bean/ai_draw_img_details_bean.dart';

/// AI 图片首页的分组模块。
class ImageSectionBlock extends StatefulWidget {
  const ImageSectionBlock({
    super.key,
    required this.isActive,
    required this.section,
    required this.items,
    required this.onOpenMore,
    this.onSelectItem,
  });

  final bool isActive;
  final ImageCategoryBean section;
  final List<AiDrawImgDetailsBean> items;
  final VoidCallback onOpenMore;
  final Function(int)? onSelectItem;

  @override
  State<ImageSectionBlock> createState() => _ImageSectionBlockState();
}

class _ImageSectionBlockState extends State<ImageSectionBlock>
    with WidgetsBindingObserver {
  static const double _playThreshold = 0.6;
  final Map<int, double> _visibleFractions = <int, double>{};
  double _sectionVisibleFraction = 0;

  String get _title => widget.section.title ?? '';

  String? get _iconUrl => widget.section.iconUrl;

  bool get _hasTitleIcon => _iconUrl != null && _iconUrl!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestVisibilityRefresh();
  }

  @override
  void didUpdateWidget(covariant ImageSectionBlock oldWidget) {
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

  void _requestVisibilityRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      VisibilityDetectorController.instance.notifyNow();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  imageUrl: _iconUrl!.trim(),
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    return ByWidgetsUtil.activityIndicator(isNormal: false);
                  },
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              _title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: widget.onOpenMore,
              child: Container(
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
        const SizedBox(height: 12),
        VisibilityDetector(
          key: Key('image-home-section-${widget.section.id}'),
          onVisibilityChanged: (VisibilityInfo info) {
            final double fraction = info.visibleFraction;
            if ((_sectionVisibleFraction - fraction).abs() > 0.01) {
              setState(() {
                _sectionVisibleFraction = fraction;
              });
            }
          },
          child: SizedBox(
            height: 144.w,
            child: ListView.separated(
              // 图片首页所有分组都采用横滑素材卡布局。
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => ImageGalleryCard(
                data: widget.items[index],
                enablePreviewVideo:
                    widget.isActive &&
                    _sectionVisibleFraction > 0 &&
                    (_visibleFractions[index] ?? 0) >= _playThreshold,
                onVisibilityChanged: (double fraction) {
                  final double old = _visibleFractions[index] ?? -1;
                  if ((old - fraction).abs() > 0.01) {
                    setState(() {
                      _visibleFractions[index] = fraction;
                    });
                  }
                },
                onTap: () {
                  widget.onSelectItem?.call(index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// AI 图片单个素材卡。
class ImageGalleryCard extends StatefulWidget {
  const ImageGalleryCard({
    super.key,
    required this.data,
    required this.onTap,
    this.enablePreviewVideo = true,
    this.onVisibilityChanged,
  });

  final AiDrawImgDetailsBean data;
  final Function() onTap;
  final bool enablePreviewVideo;
  final ValueChanged<double>? onVisibilityChanged;

  @override
  State<ImageGalleryCard> createState() => _ImageGalleryCardState();
}

class _ImageGalleryCardState extends State<ImageGalleryCard> {
  static const double _playThreshold = 0.6;
  double _visibleFraction = 0;

  @override
  Widget build(BuildContext context) {
    final bool shouldPlay =
        widget.enablePreviewVideo &&
        widget.data.hasPreviewVideo &&
        _visibleFraction >= _playThreshold;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 108.w,
          height: 144.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF151515),
          ),
          child: VisibilityDetector(
            key: Key('image-gallery-card-${widget.data.id}'),
            onVisibilityChanged: (VisibilityInfo info) {
              final double fraction = info.visibleFraction;
              if ((_visibleFraction - fraction).abs() > 0.01) {
                if (mounted) {
                  setState(() {
                    _visibleFraction = fraction;
                  });
                }
              }
              widget.onVisibilityChanged?.call(fraction);
            },
            child: Stack(
              children: <Widget>[
                SizedBox(
                  height: 144.w,
                  width: 108.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: widget.data.hasPreviewVideo
                        ? IgnorePointer(
                            child: VideoPlayerWidget(
                              key: ValueKey(
                                'image-gallery-preview-${widget.data.id}',
                              ),
                              url: widget.data.normalizedPreviewVideoUrl,
                              coverUrl: widget.data.picUrl,
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
                            imageUrl: widget.data.picUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return ByWidgetsUtil.activityIndicator(
                                isNormal: false,
                              );
                            },
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            errorWidget: (context, url, error) =>
                                const SizedBox.shrink(),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(18),
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
                          widget.data.displayTitle,
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
