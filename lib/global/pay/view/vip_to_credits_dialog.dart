/*
 * @Author: duncy
 * @Date: 2025-12-03 16:08:25
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-08 14:00:31
 * @FilePath: /ling_bao/lib/global/pay/view/vip_to_credits_dialog.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/extentions.dart';
import 'package:ling_bao/global/ui/colors.dart';

import '../../user/user.dart';

class VipToCreditsDialogManager {
  static void showRetainDialog({Function()? close, Function()? action}) {
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (context) {
        return VipToCreditsDialog(close: close, action: action);
      },
    );
  }
}

class VipToCreditsDialog extends StatelessWidget {
  const VipToCreditsDialog({super.key, this.close, this.action});

  final Function()? close;
  final Function()? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 494.w,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 60.w),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/pay/icon_vip_credits_bg.png'),
            ),
          ),
          child: GestureDetector(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ByText.text(
                    text: 'Fuel your next novel \n Create more worlds!',
                    textColor: ByColor.colorF8.withAlphaValue(0.7),
                    maxLines: 2,
                    fontSize: 16.sp,
                  ),
                  SizedBox(height: 20.w),
                  SizedBox(
                    height: 48.w,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ///当用户是vip时才有下一步
                            Get.back();
                            if (Get.find<UserController>().isVip) {
                              action?.call();
                            } else {
                              close?.call();
                            }
                          },
                          child: Center(
                            child: ByText.text(
                              text: 'CLAIM POINTS NOW',
                              // textColor: ByColor.colorF1,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 69.w),
                ],
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -20.w),
          child: GestureDetector(
            onTap: () {
              Get.back();
              close?.call();
            },
            child: Image.asset(
              'assets/home/main/dialog_close.png',
              width: 40.w,
              height: 40.w,
            ),
          ),
        ),
      ],
    );
  }
}
