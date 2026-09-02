import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/assets_data.dart';
import '../../common/language_str.dart';
import '../../util/by_nav_router_utils.dart';
import '../../util/by_screen_utils.dart';
import '../widget/by_text.dart';

typedef AssetsPickerTypeSelectCallback = void Function(int);
bool isSelect = false;

///资源选择弹窗
class ByHyAssetsPickerDialog extends StatelessWidget {
  final AssetsPickerTypeSelectCallback onSelected;
  final String? albumTitle;
  final String? cameraTitle;
  final AssetsPickerTypeSelectCallback? onCancel;
  const ByHyAssetsPickerDialog({
    super.key,
    required this.onSelected,
    this.albumTitle,
    this.cameraTitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    isSelect = false;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, p0) {
        if (!isSelect) {
          onCancel?.call(-1);
        }
      },
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: EdgeInsets.only(
              left: 15.w,
              right: 15.w,
              top: 10.h,
              bottom: 15.h + ByScreenUtils.bottomSafeHeight,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        onCancel?.call(-1);
                        ByNavRouterUtils.goBack(context);
                      },
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        alignment: Alignment.center,
                        child: Image.asset(
                          AssetsData.iconCloseDark,
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildMenuItem(
                      icon: AssetsData.iconMediaAlbum,
                      title: albumTitle ?? LanguageStr.album,
                      index: 0,
                      onSelected: (index) {
                        isSelect = true;
                        onSelected(index);
                      },
                    ),
                    const Spacer(),
                    _buildMenuItem(
                      icon: AssetsData.iconMediaTakePhoto,
                      title: cameraTitle ?? LanguageStr.camera,
                      index: 1,
                      onSelected: (index) {
                        isSelect = true;
                        onSelected(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _buildMenuItem({
    required AssetsPickerTypeSelectCallback onSelected,
    required String icon,
    required String title,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        onSelected(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        width: 160.w,
        // height: 160.w,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 53.h),
            Image.asset(icon, width: 40.w, height: 40.w),
            const SizedBox(height: 41),
            ByText.text(
              text: title,
              fontSize: 14.sp,
              textColor: const Color(0xfF0E1840),
            ),
            SizedBox(height: 18.5.h),
          ],
        ),
      ),
    );
  }
}
