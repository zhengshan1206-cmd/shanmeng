/*
 * @Author: duncy
 * @Date: 2026-01-06 10:56:09
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-11 16:30:42
 * @FilePath: /ling_bao/lib/global/login/view/first_login_dialog.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/main/main_controller.dart';
import 'package:ling_bao/global/ui/colors.dart';

class FirstLoginDialogManager {
  static void showLoginDialog(bool isFirstLogin) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return FirstLoginDialog(isFirstLogin: isFirstLogin);
      },
    );
  }
}

class FirstLoginDialog extends StatelessWidget {
  const FirstLoginDialog({super.key, required this.isFirstLogin});

  final bool isFirstLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 494.w,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/global/login/icon_login_success${isFirstLogin ? '_first' : ''}_bg.png',
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isFirstLogin
                  ? Container(
                      height: 80.w,
                      padding: EdgeInsets.symmetric(horizontal: 75.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ByText.text(
                            text: '10K',
                            textColor: ByColor.colorF8,
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 24.w),
                          SizedBox(
                            width: 120.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ByText.text(
                                  text: 'Congratulations!',
                                  textColor: ByColor.colorF8,
                                  fontSize: 15.sp,
                                ),
                                ByText.text(
                                  text: 'You’ve received',
                                  textColor: ByColor.colorF8,
                                  fontSize: 13.sp,
                                ),
                                ByText.text(
                                  text: '10K Credits',
                                  textColor: ByColor.colorG3,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ByText.text(
                      text: 'Start creating story now.',
                      textColor: ByColor.colorF2,
                      fontSize: 17.sp,
                    ),
              SizedBox(height: 60.w),
              GestureDetector(
                onTap: () {
                  Get.back();
                  final MainController mainController =
                      Get.find<MainController>();
                  mainController.tabChanged(0);
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: ByText.text(
                          text: 'Start Creating',
                          textColor: ByColor.colorF0,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isFirstLogin ? 16.w : 72.w),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w),
                    color: ByColor.colorF0.withAlphaValue(0.1),
                  ),
                  child: Image.asset('assets/global/common/btn_close.png'),
                ),
              ),
              SizedBox(height: 40.w),
            ],
          ),
        ),
      ),
    );
  }
}
