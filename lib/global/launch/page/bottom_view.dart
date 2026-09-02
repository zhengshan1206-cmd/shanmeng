import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/ui/view/by_widgets_util.dart';
import '../../../core/ui/widget/by_button.dart';
import '../../../core/ui/widget/by_text.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../global/ui/colors.dart';
import '../../user/user.dart';

///底部视图，单生成下一步，切换vip
// ignore: must_be_immutable
class BottomView extends StatelessWidget {
  BottomView({
    super.key,
    this.words = '',
    this.mode = 0,
    this.nextBtnText = 'Next',
    this.toggleMode,
    this.showWords = true,
    this.nextStep,
    this.padding,
    this.backgroundColor = ByColor.colorC1,
    this.titleColor = ByColor.colorF8,
    this.arrowStyle = 0,
    this.margin,
    this.isBottom = true,
    this.showNextIcon = true,
    this.enable = true,
  });

  ///字数
  final String? words;

  ///切换普通和专业版模式
  final Function? toggleMode;

  ///下一步
  final Function? nextStep;

  ///初始化模式，0为普通只有下一步模式，1为普通版模式， 2为专业版模式
  final int? mode;

  ///下一步
  final String? nextBtnText;

  ///是否显示字数展示
  final bool? showWords;

  ///是否可点击
  final bool? enable;

  ///是否显示下一步icon
  final bool? showNextIcon;

  final bool? isBottom;

  final double? padding;

  final double? margin;

  final userController = Get.find<UserController>();

  Rx<String> userWords = '0'.obs;

  final Color backgroundColor;
  final Color titleColor;
  final int arrowStyle;

  @override
  Widget build(BuildContext context) {
    Widget widget = _buildNormalBottomView();
    if (mode == 1) {
      widget = _buildProfessionalBottomNormalView();
    } else if (mode == 2) {
      widget = _buildProfessionalBottomView();
    }
    return Opacity(
      opacity: enable! ? 1.0 : 0.3,
      child: Column(children: [if (showWords!) _buildWordsView(), widget]),
    );
  }

  Widget _buildWordsView() {
    bool isVip = userController.userInfoBean.value?.isVip == 1;
    userWords.value = userController.getUserWords();
    return SizedBox(
      height: 36.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding ?? 12.w),
        child: Row(
          children: [
            words!.isNotEmpty
                ? _wordsView('Consume ', '$words', isVip: isVip)
                : isVip
                ? Container()
                : _buildBusinessView(),
            const Spacer(),
            // if (words!.isNotEmpty && !isVip) _buildBusinessView(),
            // if (words!.isNotEmpty && !isVip)
            //   SizedBox(
            //     width: 4.w,
            //   ),
            Obx(() => _wordsView('Remain ', userWords.value)),
            // Obx(() => goBuyVip()),
          ],
        ),
      ),
    );
  }

  ///商业化提示
  Widget _buildBusinessView() {
    return Row(
      children: [
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () {
            userController.checkPreLogin(
              source: 'bottom',
              actionCallback: () {
                userController.jumpToPayPage(source: 'bottom');
              },
            );
          },
          child: ByText.text(
            text: 'earn',
            fontSize: 12.sp,
            textColor: Color(0XFF98FC4A),
          ),
        ),
        SizedBox(width: 4.w),
        Container(
          width: 1.w,
          height: 13.w,
          color: Colors.white.withValues(alpha: 0.64),
        ),
        goBuyVip(),
      ],
    );
  }

  ///字数显示子组件
  Widget _wordsView(
    String preString,
    String words, {
    String? sufString,
    bool? isVip,
  }) {
    return GestureDetector(
      onTap: () {
        userController.jumpToPayPage(source: 'bottom');
      },
      child: Row(
        children: [
          ByWidgetsUtil.commonRichText(
            fontSize: 12.sp,
            textColor: ByColor.colorF2,
            fontWeight: FontWeight.normal,
            texts: [
              TextSpan(text: preString),
              TextSpan(
                text: words,
                style: const TextStyle(color: ByColor.colorC1),
              ),
              TextSpan(text: sufString ?? ' Credits'),
            ],
          ),
          // if (isVip == false)
          //   Padding(
          //     padding: EdgeInsets.only(
          //       bottom: 0.w,
          //     ),
          //     child: Text(
          //       " VIP needed",
          //       style: TextStyle(
          //         color: Color(0XFFFE5024),
          //         fontSize: 12.sp,
          //         fontWeight: FontWeight.normal,
          //       ),
          //     ),
          //   )
        ],
      ),
    );
  }

  ///无专业版模式下底部按钮
  Widget _buildNormalBottomView() {
    ///立即生成
    return Container(
      height: 56.w + (isBottom! ? ByScreenUtils.bottomSafeHeight : 0),
      padding: EdgeInsets.only(
        left: padding ?? 12.w,
        right: padding ?? 12.w,
        top: margin ?? 4.w,
        bottom:
            (isBottom! ? ByScreenUtils.bottomSafeHeight : 0) + (margin ?? 4.w),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 56.w - (margin != null ? margin! * 2 : 4.w),
            width: double.infinity,
            child: ByButton.textButton(
              titleColor: titleColor,
              backgroundColor: backgroundColor,
              title: nextBtnText!,
              onPressed: () {
                if (enable!) {
                  nextStep?.call();
                }
              },
            ),
          ),
          if (showNextIcon!)
            Positioned(
              right: 20.w,
              top: 16.w,
              bottom: 16.w,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/home/create/icon_home_create_continue${arrowStyle == 0 ? '' : '_white'}.png',
                ),
              ),
            ),
        ],
      ),
    );
  }

  ///有专业版普通模式下底部按钮
  Widget _buildProfessionalBottomNormalView() {
    return Container(
      height: 60.w + (isBottom! ? ByScreenUtils.bottomSafeHeight : 0),
      padding: EdgeInsets.only(
        left: padding ?? 12.w,
        right: padding ?? 12.w,
        bottom: (isBottom! ? ByScreenUtils.bottomSafeHeight : 0) + 4.w,
      ),
      child: SizedBox(
        height: 60.w,
        child: Row(
          children: [
            ByButton.textButton(
              title: '切换专业版',
              onPressed: () {
                ///切换模式
                userController.checkPreLogin(
                  source: 'bottom',
                  actionCallback: () {
                    toggleMode?.call();
                  },
                );
              },
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: SizedBox(
                height: 48.w,
                child: ByButton.textButton(
                  titleColor: Colors.black,
                  title: 'Next',
                  onPressed: () {
                    userController.checkPreLogin(
                      source: 'bottom',
                      actionCallback: () {
                        userWords.value = userController.getUserWords();
                        nextStep?.call();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///有专业版专业模式下底部按钮
  Widget _buildProfessionalBottomView() {
    return Container(
      height: 60.w + (isBottom! ? ByScreenUtils.bottomSafeHeight : 0),
      padding: EdgeInsets.only(
        left: padding ?? 12.w,
        right: padding ?? 12.w,
        bottom: (isBottom! ? ByScreenUtils.bottomSafeHeight : 0) + 4.w,
      ),
      child: SizedBox(
        height: 60.w,
        child: Row(
          children: [
            SizedBox(
              height: 48.w,
              child: ByButton.textButton(
                titleColor: ByColor.colorC1,
                backgroundColor: ByColor.color2E3038,
                title: '切换普通版',
                onPressed: () {
                  ///切换模式
                  userController.checkPreLogin(
                    source: 'bottom',
                    actionCallback: () {
                      toggleMode?.call();
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: ByButton.textButton(
                title: 'Next',
                onPressed: () {
                  userController.checkPreLogin(
                    source: 'bottom',
                    actionCallback: () {
                      userWords.value = userController.getUserWords();
                      nextStep?.call();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///非vip 去充值
  Widget goBuyVip() {
    return GestureDetector(
      onTap: () {
        userController.jumpToPayPage(source: 'bottom');
      },
      child: Row(
        children: [
          ByWidgetsUtil.commonRichText(
            fontSize: 12.sp,
            textColor: ByColor.colorF2,
            fontWeight: FontWeight.normal,
            texts: [
              const TextSpan(
                text: "Charge",
                style: TextStyle(color: Color(0XFF98FC4A)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
