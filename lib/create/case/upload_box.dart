import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/create/create_controller.dart';

class CreateUploadBox extends StatefulWidget {
  const CreateUploadBox({super.key, required this.type});

  final CreateFlowType type;

  @override
  State<CreateUploadBox> createState() => _CreateUploadBoxState();
}

class _CreateUploadBoxState extends State<CreateUploadBox> {
  String localImagePath = '';
  String remoteImageUrl = '';
  bool loading = false;
  final CreateController controller = Get.find<CreateController>();

  bool get _hasImage => localImagePath.isNotEmpty || remoteImageUrl.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final String currentImageUrl =
        controller.videoParams['images']?.toString() ?? '';
    if (currentImageUrl.isNotEmpty && currentImageUrl != 'null') {
      remoteImageUrl = currentImageUrl;
    }
  }

  void _pickImage() {
    FocusScope.of(context).unfocus();
    controller.uploadImage(
      onSuccess: (url, path) {
        controller.imageChanged(url);
        setState(() {
          remoteImageUrl = url;
          localImagePath = path;
        });
      },
    );
  }

  void _clearImage() {
    controller.imageChanged('');
    setState(() {
      localImagePath = '';
      remoteImageUrl = '';
    });
  }

  Widget _buildImage({
    required BoxFit fit,
    Widget Function(BuildContext, String, Object?)? errorBuilder,
  }) {
    if (localImagePath.isNotEmpty) {
      return Image.file(File(localImagePath), fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: remoteImageUrl,
      fit: fit,
      errorWidget: errorBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _hasImage ? null : _pickImage,
      child: Container(
        height: 170.w,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.w),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (_hasImage) ...<Widget>[
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: _buildImage(
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Color(0xFF232323)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.24)),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.30),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.34),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: _buildImage(
                    fit: BoxFit.fitHeight,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  right: 12.w,
                  bottom: 12.w,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clearImage,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(14.w),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16.w,
                      ),
                    ),
                  ),
                ),
              ] else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add_rounded,
                      color: Colors.white.withValues(alpha: 0.82),
                      size: 34.w,
                    ),
                    SizedBox(height: 8.w),
                    Text(
                      '上传图片',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.w),
                    Text(
                      '图片仅支持jpg/png格式，文件不超过10M',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.32),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              if (loading)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
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
