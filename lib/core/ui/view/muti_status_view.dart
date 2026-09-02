import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/dialog/loading_dialog.dart';
import 'package:ling_bao/core/ui/widget/by_button.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';

import '../../../global/ui/colors.dart';
import '../../../global/ui/theme.dart';

enum EmptyActionType {
  ///只显示文字
  text,

  ///只显示按钮
  button,

  ///按钮文字都显示
  all,
}

enum MultiStatusType {
  ///内容
  statusContent,

  ///加载中
  statusLoading,

  ///无数据
  statusEmpty,

  ///数据错误
  statusError,

  ///无网络
  statusNoNetWork,

  ///自定义
  statusCustom,
}

class MultiStatusView extends StatefulWidget {
  const MultiStatusView({
    super.key,
    required this.child,
    this.currentStatus = MultiStatusType.statusContent,
    this.loadingWidget,
    this.errorWidget,
    this.noNetWorkWidget,
    this.customWidget,
    this.emptyWidget,
    this.emptyText,
    this.emptyActionText,
    this.emptyActionType = EmptyActionType.text,
    this.hasAppBar = true,
    this.backgroundColor = Colors.transparent,
    this.action,
    this.emptyAction,
    this.actionText,
    this.scrollController,
  });

  final Widget child;
  final MultiStatusType currentStatus;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? noNetWorkWidget;
  final Widget? customWidget;

  final Widget? emptyWidget;
  final EmptyActionType emptyActionType;
  final String? emptyText;
  final String? emptyActionText;

  final VoidCallback? action;
  final VoidCallback? emptyAction;
  final String? actionText;

  final bool hasAppBar;

  final Color backgroundColor;

  final ScrollController? scrollController;

  @override
  State<MultiStatusView> createState() => _MultiStatusViewState();
}

class _MultiStatusViewState extends State<MultiStatusView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (widget.currentStatus) {
      case MultiStatusType.statusContent:
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: widget.backgroundColor,
              height: constraints.maxHeight,
              child: widget.child,
            );
          },
        );
      case MultiStatusType.statusLoading:
        return _buildLoadingWidget();
      case MultiStatusType.statusEmpty:
        return _buildEmptyWidget();
      case MultiStatusType.statusError:
        return _buildErrorWidget();
      case MultiStatusType.statusNoNetWork:
        return _buildNoNetWorkWidget();
      case MultiStatusType.statusCustom:
        return _buildCustomWidgetWidget();
    }
  }

  Widget _buildLoadingWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
              bottom: !widget.hasAppBar
                  ? 0
                  : safeAreaEdgeInsets.top + kToolbarHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.loadingWidget != null
                  ? [widget.loadingWidget!]
                  : [loadingIndicator()],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    List<Widget> content = widget.emptyWidget != null
        ? [widget.emptyWidget!]
        : [
            Image.asset(
              'assets/global/common/icon_content_empty.png',
              width: 200.w,
              height: 150.w,
            ),
            SizedBox(height: 10.h),
            ..._getActions(widget.emptyActionType),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: widget.scrollController,
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...content,
                Flexible(
                  child: SizedBox(
                    height: !widget.hasAppBar
                        ? 0
                        : safeAreaEdgeInsets.top + kToolbarHeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
              bottom: !widget.hasAppBar
                  ? 0
                  : safeAreaEdgeInsets.top + kToolbarHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.errorWidget != null
                  ? [widget.errorWidget!]
                  : [ByText.text(text: "服务错误", fontSize: 16.sp)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoNetWorkWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
              bottom: !widget.hasAppBar
                  ? 0
                  : safeAreaEdgeInsets.top + kToolbarHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.noNetWorkWidget != null
                  ? [widget.noNetWorkWidget!]
                  : [
                      ByText.text(
                        text: "网络错误，请检查您的网络",
                        fontSize: 16.sp,
                        textColor: ByColor.colorF2,
                      ),
                      SizedBox(height: 20.w),
                      Container(
                        height: 36.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: ByButton.textButton(
                          padding: const EdgeInsets.all(0),
                          fontSize: 13.sp,
                          titleColor: Colors.black,
                          title: 'Retry',
                          onPressed: () {
                            widget.action?.call();
                          },
                        ),
                      ),
                    ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomWidgetWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
              bottom: !widget.hasAppBar
                  ? 0
                  : safeAreaEdgeInsets.top + kToolbarHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.customWidget != null
                  ? [widget.customWidget!]
                  : [ByText.text(text: "自定义布局", fontSize: 16.sp)],
            ),
          ),
        );
      },
    );
  }

  List _getActions(EmptyActionType emptyActionType) {
    switch (emptyActionType) {
      case EmptyActionType.all:
        return [
          ByText.text(
            text: widget.emptyText ?? '暂无内容',
            fontSize: 16.sp,
            textColor: ByColor.colorF2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 22.h),
          SizedBox(height: 20.w),
          SizedBox(
            width: 80.w,
            height: 30.w,
            // child: ByButton.gradientBtn(
            //   padding: const EdgeInsets.all(0),
            //   fontSize: 13.sp,
            //   textColor: Colors.black,
            //   title: widget.emptyActionText ?? '重新加载',
            //   onClick: (){
            //   widget.emptyAction?.call();
            // }),
          ),
        ];
      case EmptyActionType.text:
        return [
          ByText.text(
            text: widget.emptyText ?? '暂无内容',
            fontSize: 16.sp,
            textColor: ByColor.colorF2,
            textAlign: TextAlign.center,
          ),
        ];
      case EmptyActionType.button:
        return [
          SizedBox(height: 20.w),
          SizedBox(
            width: 80.w,
            height: 30.w,
            // child: ByButton.gradientBtn(
            //   padding: const EdgeInsets.all(0),
            //   fontSize: 13.sp,
            //   textColor: Colors.black,
            //   title: widget.emptyActionText ?? '重新加载',
            //   onClick: (){
            //   widget.emptyAction?.call();
            // }),
          ),
        ];
    }
  }

  @override
  bool get wantKeepAlive => true;

  Widget loadingIndicator({Color color = ByColor.colorC1}) {
    return const Center(child: LoadingView());
  }
}
