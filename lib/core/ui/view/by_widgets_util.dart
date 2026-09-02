import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ling_bao/core/common/assets_data.dart';
import 'package:ling_bao/core/common/byhy_colors.dart';
import 'package:ling_bao/core/ui/dialog/by_dialog_util.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_nav_router_utils.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:ling_bao/global/ui/colors.dart';

class ByWidgetsUtil {
  static PreferredSize appBarBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(1.h), // 分割线的高度
      child: Container(
        color: ByHyColorUtil.commonPageBgColor, // 分割线的颜色
        height: 1.h, // 分割线的高度
      ),
    );
  }

  /// 高斯模糊
  static Widget gaussianBlur({
    required Widget child,
    double? sigmaX,
    double? sigmaY,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX ?? 3, sigmaY: sigmaY ?? 3),
      child: child,
    );
  }

  static Widget closeBtnForGuid({
    BuildContext? context,
    required void Function() onTap,
  }) {
    return Positioned(
      left: 10.w,
      top: ByScreenUtils.topSafeHeight + (56.h - 36.h) * 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
          onTap.call();
        },
        child: SizedBox(
          height: 36.h,
          width: 80.w,
          child: ByWidgetsUtil.commonContainer(
            alignment: Alignment.center,
            child: ByText.text(text: "关闭提示", fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  /// 通用 appbar 组件
  static AppBar appBar({
    required BuildContext context,
    required String title,
    Widget? leaing,
    void Function()? onPop,
    bool popScop = false,
    bool showBottmLine = true,
    String? contents,
    String? popScopTitle,
    String? popScopConfirmBtnTitle,
    Function? popScopConfirmCallback,
    String? popScopCancelBtnTitle,
    Function? popScopCancelCallback,
    bool popScopeExt = true,
    List<Widget>? actions,
    Color? backgroundColor,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return AppBar(
      bottom: showBottmLine ? appBarBottom() : null,
      elevation: 0.1,
      systemOverlayStyle: systemOverlayStyle,
      leading:
          leaing ??
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              FocusScope.of(context).unfocus();
              if (popScop) {
                final navigator = Navigator.of(context);
                final canPop =
                    await ByDialogUtil.showPopScopeDialog(
                      context: context,
                      contents: contents,
                      title: popScopTitle,
                      confirmBtnTitle: popScopConfirmBtnTitle,
                      confirmCallback: popScopConfirmCallback,
                      cancelBtnTitle: popScopCancelBtnTitle,
                      cancelCallback: popScopCancelCallback,
                    ) ??
                    false;
                if (canPop) {
                  /// 执行返回前的操作
                  onPop?.call();
                  if (popScopeExt) {
                    navigator.pop();
                  }
                }
                return;
              }

              if (onPop != null) {
                onPop();
                return;
              }
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(AssetsData.iconBack, width: 16, height: 16),
            ),
          ),
      title: ByText.text(
        text: title,
        textColor: ByColor.colorF8,
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: backgroundColor ?? ByHyColorUtil.whiteColor,
      actions: actions,
    );
  }

  static Widget activityIndicator({
    double? radius,
    Color? color,
    bool isNormal = true,
  }) {
    if (isNormal) {
      return Center(
        child: CupertinoActivityIndicator(
          radius: radius ?? 12.w,
          color: color ?? ByHyColorUtil.tabTextColorSelected,
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? ByColor.colorC1,
        strokeCap: StrokeCap.round,
      ),
    );
  }

  static Widget futuerBuilderWidget<T>({
    Widget? errorWidget,
    Widget? waitingWidget,
    required Future<T>? future,
    required Widget Function(BuildContext ctx, T? data) builder,
  }) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          /// 等待时显示的加载指示器
          return waitingWidget ??
              CircularProgressIndicator(
                color: ByHyColorUtil.tabTextColorSelected,
                strokeWidth: 15.w,
              );
        } else if (snapshot.hasError) {
          /// 错误时显示的内容
          return errorWidget ?? Text("Error: ${snapshot.error}");
        } else {
          return builder(context, snapshot.data);
        }
      },
      future: future,
    );
  }

  static Positioned positionedFillTextArea(
    BuildContext context,
    TextEditingController controller, {
    EdgeInsetsGeometry? padding,
    String? hintText,
    double? fontSize,
  }) {
    return Positioned.fill(
      child: Padding(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
        child: TextField(
          maxLines: null,
          expands: false,
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: fontSize ?? 14.sp,
              color: ByHyColorUtil.commonTextColor,
            ),
            hintText: hintText ?? "请输入文字内容...",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ByHyColorUtil.commonTextColor.withValues(alpha: 0.5),
            ),
          ),
          cursorColor: ByHyColorUtil.commonTextColor,
          // cursorHeight: 15.sp,
        ),
      ),
    );
  }

  /// 通用图片按钮组件
  static GestureDetector imageBtn({
    required String image,
    required double width,
    required double height,
    required double imageWidth,
    required double imageHeight,
    required void Function() onClick,
    Color? bgColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onClick(),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              bgColor ?? ByHyColorUtil.loginBtnBgColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.w),
        ),
        child: Image.asset(image, width: imageWidth, height: imageHeight),
      ),
    );
  }

  static Widget commonContainer({
    Color? bgColor,
    double? borerRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    AlignmentGeometry? alignment,
    required Widget child,
    double? width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        boxShadow: boxShadow,
        color: bgColor ?? ByHyColorUtil.whiteColor,
        borderRadius: BorderRadius.circular(borerRadius ?? 12.w),
        border: border,
      ),
      padding: padding,
      margin: margin,
      alignment: alignment,
      child: child,
    );
  }

  /// 通用按钮组件
  static GestureDetector commonBtn({
    BuildContext? context,
    required String title,
    required void Function() onClick,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
    Color? textColor = ByHyColorUtil.whiteColor,
    Color? bgColor = ByHyColorUtil.loginBtnBgColor,
    double? borderRadius,
    double? fontSize,
    Color? borderColor,
    double? borderWidth,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      child: Container(
        alignment: Alignment.center,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          color: bgColor,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor, width: borderWidth ?? 1),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            decoration: TextDecoration.none,
            fontSize: fontSize ?? 12.sp,
            fontWeight: fontWeight ?? FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 通用按钮组件
  static GestureDetector commonBtnWithRichText({
    BuildContext? context,
    required Widget title,
    required void Function() onClick,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
    Color? bgColor = ByHyColorUtil.loginBtnBgColor,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      child: Container(
        alignment: Alignment.center,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          color: bgColor,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor, width: borderWidth ?? 1),
        ),
        child: title,
      ),
    );
  }

  /// 通用按钮组件
  static GestureDetector gradientBtn({
    BuildContext? context,
    required String title,
    required void Function() onClick,
    EdgeInsetsGeometry? padding,
    Color? textColor = ByHyColorUtil.whiteColor,
    Gradient? gradient,
    double? fontSize,
    FontWeight? fontWeight,
    double? borderRadius,
    BorderRadiusGeometry? csutomerBorderRadius,
  }) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      child: Container(
        alignment: Alignment.center,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius:
              csutomerBorderRadius ??
              BorderRadius.circular(borderRadius ?? 24.w),
          gradient: gradient ?? ByColor.colorG1(),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize ?? 12.sp,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  /// 通用按钮有图带渐变的按钮组件
  static GestureDetector gradientImageBtn({
    BuildContext? context,
    required String title,
    required void Function() onClick,
    EdgeInsetsGeometry? padding,
    Color? textColor = ByColor.colorF2,
    Gradient? gradient,
    double? fontSize,
    FontWeight? fontWeight,
    double? borderRadius,
    BorderRadiusGeometry? customBorderRadius,
    Color? bgColor,
    String? image,
    double? imageSize,
  }) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      child: Container(
        alignment: Alignment.center,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: bgColor == null
            ? BoxDecoration(
                borderRadius:
                    customBorderRadius ??
                    BorderRadius.circular(borderRadius ?? 15.w),
                gradient: gradient ?? ByColor.colorG1(),
                color: bgColor ?? ByColor.colorBg2,
              )
            : BoxDecoration(
                borderRadius:
                    customBorderRadius ??
                    BorderRadius.circular(borderRadius ?? 15.w),
                color: bgColor,
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Image.asset(
                image,
                width: imageSize ?? 16,
                height: imageSize ?? 16,
              ),
            if (image != null && title.isNotEmpty) const SizedBox(width: 4),
            if (title.isNotEmpty)
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  textBaseline: TextBaseline.ideographic,
                  fontSize: fontSize ?? 17.sp,
                  fontWeight: fontWeight ?? FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget physicalModel({
    Color color = Colors.black,
    double elevation = 10,
    required Widget child,
  }) {
    return PhysicalModel(color: color, elevation: elevation, child: child);
  }

  /// 通用Text组件
  static Text commonText({
    String? fontFamily,
    required String text,
    double? fontSize,
    FontWeight? fontWeight = FontWeight.normal,
    TextAlign? textAlign,
    Color? textColor,
    int? maxLines,
    TextDecoration? decoration,
    Color? decorationColor,
    double? height,
    double? decorationThickness,
    Color? bgColor,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines ?? 1,
      overflow: TextOverflow.ellipsis,
      // textHeightBehavior: const TextHeightBehavior(
      //   applyHeightToFirstAscent: true,
      //   applyHeightToLastDescent: false,
      // ),
      style: TextStyle(
        height: height,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        fontSize: fontSize ?? 14.sp,
        decoration: decoration ?? TextDecoration.none,
        decorationThickness: decorationThickness,
        color: textColor ?? ByHyColorUtil.commonTextColor,
        decorationColor:
            decorationColor ?? ByHyColorUtil.whiteColor.withValues(alpha: 0.5),
        backgroundColor: bgColor ?? Colors.transparent,
      ),
    );
  }

  /// 通用Text组件
  static RichText commonRichText({
    String? fontFamily,
    required List<InlineSpan> texts,
    double? height,
    double? fontSize,
    FontWeight? fontWeight = FontWeight.normal,
    Color? textColor,
    int? maxLines,
    TextAlign? textAlign,
    TextDecoration? decoration,
  }) {
    return RichText(
      maxLines: maxLines ?? 1,
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(
        text: "",
        children: texts,
        style: TextStyle(
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          height: height,
          fontSize: fontSize ?? 14.sp,
          decoration: decoration ?? TextDecoration.none,
          color: textColor ?? ByHyColorUtil.commonTextColor,
        ),
      ),
    );
  }

  static Widget outlinedBtn({
    Color? textColor,
    double? fontSize,
    Color? borderColor,
    double? borderRadius,
    BuildContext? context,
    required String title,
    EdgeInsetsGeometry? padding,
    required void Function() onClick,
    Color? bgColor = ByHyColorUtil.whiteColor,
    FontWeight? fontWeight = FontWeight.normal,
  }) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor ?? textColor ?? ByHyColorUtil.loginBtnBgColor,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
        ),
        child: ByText.text(
          text: title,
          fontSize: fontSize,
          fontWeight: fontWeight,
          textColor: textColor ?? ByHyColorUtil.loginBtnBgColor,
        ),
      ),
    );
  }

  /// 通用提示组件
  static Widget commonTipsBar(
    String tips, {
    EdgeInsetsGeometry? padding,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double? borderRadius,
  }) {
    return Container(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
        color: const Color(0xFF2E54FF).withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: mainAxisSize,
        children: [
          Image.asset(
            "assets/mine/icon_info.png",
            width: 12.w,
            height: 12.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: ByText.text(
              text: tips,
              maxLines: 100,
              fontSize: 12.sp,
              textColor: const Color(0xFF5A4BF7),
            ),
          ),
        ],
      ),
    );
  }

  /// 通用提示组件
  static Widget commonTipsBar2({required String tips, required String title}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        color: const Color(0xFF2E54FF).withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/mine/icon_info.png",
                width: 12.w,
                height: 12.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: ByText.text(
                  text: title,
                  maxLines: 100,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  textColor: const Color(0xFF5A4BF7),
                ),
              ),
            ],
          ),
          ByText.text(
            text: tips,
            maxLines: 100,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            textColor: const Color(0xFF5A4BF7),
          ),
        ],
      ),
    );
  }

  /// 通用富文本提示组件
  static Widget commonRichTextTipsBar({required List<InlineSpan> textSpans}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        color: const Color(0xFF2E54FF).withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/mine/icon_info.png",
            width: 12.w,
            height: 12.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 5.w),
          // ByText.text(
          //   text: tips,
          //   fontSize: 12.sp,
          //   textColor: const Color(0xFF5A4BF7),
          // ),
          RichText(
            text: TextSpan(
              children: textSpans,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF5A4BF7)),
            ),
          ),
        ],
      ),
    );
  }

  /// 渐变背景容器
  static Widget gradientBgContainer({
    required Gradient? gradient,
    double? borderRadius,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    BoxBorder? border,
    required Widget child,
  }) => Container(
    alignment: alignment ?? Alignment.center,
    padding: padding ?? EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 12.w)),
      gradient:
          gradient ??
          const LinearGradient(
            colors: [Color(0xFF5C4CF7), Color(0xFF7E71FE)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
      border: border,
    ),
    child: child,
  );

  /// 渐变背景容器

  static Widget richTextThree({
    String? fontFamily,
    FontWeight? fontWeight,
    String partPre = "¥",
    required Color textColorPre,
    double? fontSizePre,
    required String partMiddle,
    required Color textColorMiddle,
    double? fontSizeMiddle,
    required String partTail,
    required Color textColorTail,
    double? fontSizeTail,
  }) {
    return RichText(
      text: TextSpan(
        text: partPre,
        style: TextStyle(
          fontFamily: fontFamily,
          color: textColorPre,
          fontSize: fontSizePre ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: partMiddle,
            style: TextStyle(
              fontFamily: fontFamily,
              color: textColorMiddle,
              fontSize: fontSizeMiddle ?? 32.sp,
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
          TextSpan(
            text: partTail,
            style: TextStyle(
              fontFamily: fontFamily,
              color: textColorTail,
              fontSize: fontSizeTail ?? 18.sp,
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget richText({
    String? fontFamily,
    FontWeight? fontWeight,
    String? unit,
    required Color textColorUnit,
    double? fontSizeUnit,
    required String partIntegral,
    required Color textColorIntegral,
    double? fontSizeIntegral,
    String? partFractional,
    Color? textColorFractional,
    double? fontSizeFractional,
  }) {
    return RichText(
      text: TextSpan(
        text: unit ?? '¥',
        style: TextStyle(
          fontFamily: fontFamily,
          color: textColorUnit,
          fontSize: fontSizeUnit ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: partIntegral,
            style: TextStyle(
              fontFamily: fontFamily,
              color: textColorIntegral,
              fontSize: fontSizeIntegral ?? 32.sp,
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
          TextSpan(
            text: partFractional != null && partFractional.isNotEmpty
                ? ".$partFractional"
                : "",
            style: TextStyle(
              fontFamily: fontFamily,
              color: textColorFractional ?? ByHyColorUtil.commonTextColor,
              fontSize: fontSizeFractional ?? 18.sp,
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
