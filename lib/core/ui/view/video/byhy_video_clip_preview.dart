import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../util/by_screen_utils.dart';
import '../../../util/byhy_assets_util.dart';
import '../../../util/extentions.dart';
import 'byhy_video_player_view_copy.dart';

class VideoClipPreview extends StatefulWidget {
  final String videoFilePath;
  final String? title;
  final bool backToHme;
  final Duration? maxDuration;

  const VideoClipPreview(
    this.videoFilePath, {
    super.key,
    this.title,
    this.backToHme = false,
    this.maxDuration,
  });

  @override
  State<VideoClipPreview> createState() => _VideoClipPreviewState();
}

class _VideoClipPreviewState extends State<VideoClipPreview> {
  _VideoClipPreviewState();
  bool exists = false;

  @override
  void initState() {
    _checkExists();

    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: AppBar(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         leading: GestureDetector(
  //           onTap: () {
  //             Navigator.pop(context);
  //           },
  //           child: Container(
  //             width: 32,
  //             height: 32,
  //             alignment: Alignment.center,
  //             child: Icon(
  //               Icons.arrow_back_ios_new,
  //               size: 18.sp,
  //               color: const Color(0XFFFFFFFF),
  //             ),
  //           ),
  //         ),
  //       ),
  //       backgroundColor: const Color(0XFF121212),
  //       body: Column(
  //         children: [
  //           Expanded(
  //             key: UniqueKey(),
  //             child: Center(
  //               child: VideoPlayerWidgetCopy(
  //                 url: widget.videoFilePath,
  //                 showFullScreenButton: false,
  //                 autoPlay: true,
  //                 maxDuration: widget.maxDuration,
  //               ),
  //             ),
  //           ),
  //           SizedBox(height: 10.h),
  //         ],
  //       ));
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0XFF121212),
  //     body: Stack(
  //       children: [
  //         Center(
  //           child: VideoPlayerWidget(
  //             url: widget.videoFilePath,
  //             showFullScreenButton: false,
  //             autoPlay: true,
  //             maxDuration: widget.maxDuration,
  //           ),
  //         ),
  //         Positioned(
  //           top: ByScreenUtils.topSafeHeight,
  //           left: 15.w,
  //           child: GestureDetector(
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Container(
  //                 width: 32,
  //                 height: 32,
  //                 alignment: Alignment.center,
  //                 child: Icon(
  //                   Icons.arrow_back_ios_new,
  //                   size: 18.sp,
  //                   color: const Color(0XFFFFFFFF),
  //                 ),
  //               )),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // 状态栏白色字体
      child: Scaffold(
        backgroundColor: const Color(0XFF121212),
        body: Stack(
          children: [
            SafeArea(
              top: true,
              bottom: false,
              child: Center(
                child: VideoPlayerWidgetCopy(
                  url: widget.videoFilePath,
                  showFullScreenButton: false,
                  autoPlay: true,
                  maxDuration: widget.maxDuration,
                ),
              ),
            ),
            // 返回按钮可选保留
            Positioned(
              top: ByScreenUtils.topSafeHeight + 10,
              left: 15.w,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlphaValue(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18.sp,
                    color: const Color(0XFFFFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkExists() async {
    final assetSearch = await ByAssetsUtil.getAssetEntityByPath(
      widget.videoFilePath,
    );
    if (assetSearch != null) {
      exists = true;
      return null;
    }
  }
}
