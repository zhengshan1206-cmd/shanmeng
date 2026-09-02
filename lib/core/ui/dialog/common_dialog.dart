import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../global/ui/colors.dart';
import '../widget/by_button.dart';
import '../widget/by_text.dart';

///一些公共弹窗
class CommonDialog extends StatelessWidget {
  final String contents;
  final String? title;
  final String? confirmBtnTitle;
  final String? cancelBtnTitle;
  final Function? confirmCallback;
  final Function? cancelCallback;
  final int? maxLine;
  final bool reverse;
  final TextAlign? textAlign;
  final bool isDanger;
  final bool confirmToBack;

  ///确认之后返回

  const CommonDialog({
    super.key,
    required this.contents,
    this.title,
    this.confirmBtnTitle,
    this.confirmCallback,
    this.cancelBtnTitle,
    this.cancelCallback,
    this.maxLine,
    this.textAlign,
    this.reverse = false,
    this.isDanger = false,
    this.confirmToBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 28.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: ByColor.colorF0,
                borderRadius: BorderRadius.circular(18.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30.h),
                  ByText.text(
                    text: title ?? "Kind Tips",
                    fontSize: 16.sp,
                    textColor: ByColor.colorF7,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 43.w),
                    child: ByText.text(
                      fontSize: 13.sp,
                      maxLines: maxLine ?? 1,
                      textColor: ByColor.colorF7.withValues(alpha: 0.7),
                      textAlign: textAlign ?? TextAlign.center,
                      text: contents,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Row(
                      children: reverse
                          ? [
                              Expanded(
                                child: SizedBox(
                                  height: 48.h,
                                  child: ByButton.textButton(
                                    title: cancelBtnTitle ?? "Cancel",
                                    fontSize: 14.sp,
                                    backgroundColor: ByColor.colorBg1
                                        .withValues(alpha: 0.3),
                                    titleColor: ByColor.colorF7,
                                    fontWeight: FontWeight.bold,
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      cancelCallback?.call();
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: SizedBox(
                                  height: 48.h,
                                  child: ByButton.textButton(
                                    title: confirmBtnTitle ?? "Confirm",
                                    fontSize: 14.sp,
                                    titleColor: ByColor.colorF1,
                                    backgroundColor: isDanger
                                        ? ByColor.colorG4
                                        : ByColor.colorF7,
                                    fontWeight: FontWeight.bold,
                                    onPressed: () {
                                      if (!confirmToBack) {
                                        Navigator.of(context).pop(true);
                                        confirmCallback?.call();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ]
                          : [
                              Expanded(
                                child: SizedBox(
                                  height: 48.h,
                                  child: ByButton.textButton(
                                    title: confirmBtnTitle ?? "Confirm",
                                    titleColor: ByColor.colorF1,
                                    backgroundColor: isDanger
                                        ? ByColor.colorG4
                                        : ByColor.colorF7,
                                    fontSize: 14.sp,
                                    onPressed: () {
                                      if (!confirmToBack) {
                                        Navigator.of(context).pop(true);
                                        confirmCallback?.call();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: SizedBox(
                                  height: 48.h,
                                  child: ByButton.textButton(
                                    title: cancelBtnTitle ?? "Cancel",
                                    fontSize: 14.sp,
                                    backgroundColor: ByColor.colorBg1
                                        .withValues(alpha: 0.3),
                                    titleColor: ByColor.colorF7,
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      cancelCallback?.call();
                                    },
                                  ),
                                ),
                              ),
                            ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          // Positioned(
          //   top: -25.h,
          //   left: ByScreenUtils.screenWidth * 0.5 - 30.w,
          //   child: Image.asset(
          //     AssetsData.iconBell,
          //     width: 60.w,
          //     height: 60.w,
          //   ),
          // ),
        ],
      ),
    );
  }
}
