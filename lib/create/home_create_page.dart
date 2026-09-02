/*
 * @Author: duncy
 * @Date: 2026-04-13 16:30:07
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-15 18:14:15
 * @FilePath: /ling_bao/lib/create/home_create_page.dart
 * @Description: 
 */


// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../create/home_create_type_dialog.dart';
import '../global/routes/app_pages.dart';
import '../global/user/user.dart';
import '../video/shared/home_assets.dart';
import '../video/shared/home_shared_widgets.dart';

/// AI 图片首页。
///
/// 当前主要承接设计稿里的分类展示和顶部功能入口，点击后统一切到创作页。
class CreateTabPage extends StatelessWidget {
  const CreateTabPage({
    required this.onOpenPayment,
    required this.onOpenProfile,
    required this.onOpenSupport,
  });

  final VoidCallback onOpenPayment;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSupport;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: ImageStarField()),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    const ImageChannelBrand(),
                    const Spacer(),
                    Obx(
                      () => !Get.find<UserController>().isVip
                          ? TopUtilityButton(
                              assetPath: HomeAssets.videoTopPremium,
                              onTap: onOpenPayment,
                            )
                          : Container(),
                    ),
                    const SizedBox(width: 8),
                    TopUtilityButton(
                      assetPath: HomeAssets.videoTopSupport,
                      onTap: onOpenSupport,
                    ),
                    const SizedBox(width: 8),
                    TopUtilityButton(
                      buttonKey: const Key('home-image-profile-button'),
                      assetPath: HomeAssets.videoTopProfile,
                      onTap: onOpenProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CreateTypeDialog(
                        category: .all,
                        showCloseButton: false,
                        onClose: () => Get.back(),
                        onSelect: (entry) {
                          Get.back();
                          Get.toNamed(Routes.create, arguments: {'entry': entry});
                        },
                      )
                
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
