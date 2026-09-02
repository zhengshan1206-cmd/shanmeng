import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../create_controller.dart';

class CreateReferenceUploadBox extends StatelessWidget {
  CreateReferenceUploadBox({super.key});

  final CreateController controller = Get.find<CreateController>();

  static const List<String> _slotNames = <String>['一', '二', '三'];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(8.w, 8.w, 10.w, 8.w),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: List<Widget>.generate(
                CreateController.referenceImageMaxCount,
                (int index) {
                  final String localPath =
                      controller.referenceLocalImagePaths[index];
                  final String remoteUrl = controller.referenceImageUrls[index];
                  final bool isUploading =
                      controller.referenceUploadingIndex.value == index;
                  final Widget child = _ReferenceUploadSlot(
                    slotName: _slotNames[index],
                    localPath: localPath,
                    remoteUrl: remoteUrl,
                    isUploading: isUploading,
                    onTap: () {
                      controller.uploadReferenceImage(index);
                    },
                    onDelete: () {
                      controller.removeReferenceImage(index);
                    },
                  );
                  if (index == CreateController.referenceImageMaxCount - 1) {
                    return child;
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: child,
                  );
                },
              ),
            ),
            SizedBox(height: 10.w),
            Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 14.w,
                  color: Colors.white.withValues(alpha: 0.34),
                ),
                SizedBox(width: 6.w),
                Text(
                  '图片仅支持jpg/png格式，文件不超过10M',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.34),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceUploadSlot extends StatelessWidget {
  const _ReferenceUploadSlot({
    required this.slotName,
    required this.localPath,
    required this.remoteUrl,
    required this.isUploading,
    required this.onTap,
    required this.onDelete,
  });

  final String slotName;
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
    return CachedNetworkImage(imageUrl: remoteUrl, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUploading ? null : onTap,
        borderRadius: BorderRadius.circular(9.w),
        child: Ink(
          width: 107.w,
          height: 143.w,
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(9.w),
            gradient: isUploading
                ? const LinearGradient(
                    colors: <Color>[Color(0xFF444444), Color(0xFF2F2F2F)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9.w),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (hasImage) Positioned.fill(child: _buildPreviewImage()),
                if (hasImage)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(9.w),
                          topRight: Radius.circular(20.w),
                          bottomRight: Radius.circular(20.w),
                          bottomLeft: Radius.circular(0),
                        ),
                      ),
                      child: Text(
                        '图$slotName',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (hasImage)
                  Positioned(
                    right: 8.w,
                    bottom: 8.w,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDelete,
                      child: Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.36),
                          borderRadius: BorderRadius.circular(13.w),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                    ),
                  ),
                if (!hasImage && !isUploading)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.add_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 36.w,
                        ),
                        SizedBox(height: 12.w),
                        Text(
                          '上传图$slotName',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isUploading)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 34.w,
                          height: 34.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.78),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
