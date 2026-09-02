/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:52:08
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 14:11:09
 * @FilePath: /ling_bao/lib/core/ui/page/base_page.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/const/const_utils.dart';
import '../../../global/ui/colors.dart';
import '../widget/by_text.dart';

// ignore: must_be_immutable
class BasePage extends GetView {
  BasePage({super.key});
  String title = '';

  ///是否显示导航栏
  bool hasAppBar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColor.colorBg1,
      appBar: hasAppBar ? buildAppBar(context) : null,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Center(
      child: ByText.text(text: title, textColor: Colors.white, fontSize: 32.sp),
    );
  }

  AppBar buildAppBar(BuildContext context, {bool isTransparent = false}) {
    return AppBar(
      backgroundColor: isTransparent ? Colors.transparent : ByColor.colorBg1,
      toolbarHeight: ConstUtils.getNavigationHeight(),
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.back();
        },
        child: Container(
          width: 56,
          height: ConstUtils.getNavigationHeight(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.asset(
              "assets/global/common/btn_back.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
      title: ByText.text(
        text: title,
        textColor: Colors.white,
        fontSize: 17.sp,
        fontWeight: FontWeight.w500,
      ),
      actions: [buildActions(context)],
    );
  }

  Widget buildActions(BuildContext context) {
    return Container();
  }
}
