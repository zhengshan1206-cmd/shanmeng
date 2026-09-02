import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../create_controller.dart';

class CreateHeadTailUploadBox extends StatelessWidget {
  CreateHeadTailUploadBox({super.key});

  final CreateController controller = Get.find<CreateController>();

  static const List<String> _slotLabels = <String>['添加首帧图片', '添加尾帧图片'];
  static const double _outerRadius = 12;
  static const double _slotSize = 164;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<String> localPaths = controller.headTailLocalImagePaths.toList(
        growable: false,
      );
      final List<String> remoteUrls = controller.headTailImageUrls.toList(
        growable: false,
      );
      final int uploadingIndex = controller.headTailUploadingIndex.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 8.w),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(_outerRadius.w),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double slotSize = math.min(
              _slotSize.w,
              constraints.maxWidth / CreateController.headTailImageCount,
            );
            return Column(
              children: <Widget>[
                SizedBox(
                  height: slotSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List<Widget>.generate(
                          CreateController.headTailImageCount,
                          (int index) => SizedBox(
                            width: slotSize,
                            height: slotSize,
                            child: _HeadTailUploadSlot(
                              label: _slotLabels[index],
                              localPath: localPaths[index],
                              remoteUrl: remoteUrls[index],
                              isUploading: uploadingIndex == index,
                              onTap: () {
                                controller.uploadHeadTailImage(index);
                              },
                              onDelete: () {
                                controller.removeHeadTailImage(index);
                              },
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.swapHeadTailImages,
                          borderRadius: BorderRadius.circular(999.w),
                          child: Ink(
                            width: 36.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(999.w),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                                width: 1.w,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/create/icons/exchange_icon.png',
                                width: 14.w,
                                height: 14.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.w),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14.w,
                      color: Colors.white.withValues(alpha: 0.34),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        '图片仅支持jpg/png格式，文件不超过10M',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.34),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

class _HeadTailUploadSlot extends StatelessWidget {
  const _HeadTailUploadSlot({
    required this.label,
    required this.localPath,
    required this.remoteUrl,
    required this.isUploading,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final String localPath;
  final String remoteUrl;
  final bool isUploading;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  bool get hasImage => localPath.isNotEmpty || remoteUrl.isNotEmpty;

  Widget _buildPreviewImage() {
    if (localPath.isNotEmpty) {
      return Image.file(File(localPath), fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: remoteUrl,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => const ColoredBox(color: Color(0xFF2C2C2C)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUploading ? null : onTap,
        borderRadius: BorderRadius.circular(9.w),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(9.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9.w),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (hasImage) Positioned.fill(child: _buildPreviewImage()),
                if (!hasImage && !isUploading)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          'assets/create/icons/upload.png',
                          width: 28.w,
                          height: 28.w,
                        ),
                        SizedBox(height: 10.w),
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isUploading)
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Color(0xFF444444), Color(0xFF2F2F2F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 34.w,
                            height: 34.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.w),
                          Text(
                            '加载中...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (hasImage)
                  Positioned(
                    right: 10.w,
                    bottom: 10.w,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDelete,
                      child: Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.36),
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 18.w,
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
