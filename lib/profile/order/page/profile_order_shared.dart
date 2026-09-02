import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileOrderPageScaffold extends StatelessWidget {
  const ProfileOrderPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actionText,
    this.onActionTap,
    this.bottomBar,
  });

  final String title;
  final Widget child;
  final String? actionText;
  final VoidCallback? onActionTap;
  final Widget? bottomBar;

  void _handleBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double sideWidth = 72;
    final List<Widget> children = [
      Padding(
        padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 0),
        child: SizedBox(
          height: 44.h,
          child: Row(
            children: [
              SizedBox(
                width: sideWidth.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _handleBack(context);
                    },
                    child: SizedBox(
                      width: 44.w,
                      height: 44.h,
                      child: Center(
                        child: Image.asset(
                          'assets/global/common/btn_back.png',
                          width: 18.w,
                          height: 18.w,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: sideWidth.w,
                child: actionText == null
                    ? const SizedBox.shrink()
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onActionTap,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: Text(
                              actionText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.68),
                                fontSize: 13.sp,
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
      SizedBox(height: 10.h),
      Expanded(child: child),
    ];

    if (bottomBar != null) {
      children.add(bottomBar!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050506),
      body: SafeArea(bottom: false, child: Column(children: children)),
    );
  }
}

class ProfileOrderCard extends StatelessWidget {
  const ProfileOrderCard({
    super.key,
    required this.child,
    this.highlighted = false,
  });

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF232325),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: Colors.white.withValues(alpha: highlighted ? 0.12 : 0.04),
        ),
      ),
      child: child,
    );
  }
}

class ProfileOrderInfoRow extends StatelessWidget {
  const ProfileOrderInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88.w,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.54),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileOrderOutlineButton extends StatelessWidget {
  const ProfileOrderOutlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.white.withValues(
      alpha: enabled ? 0.12 : 0.06,
    );
    final Color textColor = Colors.white.withValues(
      alpha: enabled ? 0.84 : 0.3,
    );

    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          width: 250.w,
          height: 42.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.w),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSubscriptionOrderCard extends StatelessWidget {
  const ProfileSubscriptionOrderCard({
    super.key,
    required this.title,
    required this.periodText,
    required this.priceText,
    required this.signTime,
    required this.executeText,
  });

  final String title;
  final String periodText;
  final String priceText;
  final String signTime;
  final String executeText;

  @override
  Widget build(BuildContext context) {
    return ProfileOrderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  periodText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                priceText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.54),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ProfileOrderInfoRow(label: '签约时间', value: signTime),
          // SizedBox(height: 10.h),
          // ProfileOrderInfoRow(label: '上次扣费时间', value: executeText),
        ],
      ),
    );
  }
}
