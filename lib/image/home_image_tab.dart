// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/image/home_image_controller.dart';
import 'package:ling_bao/core/ui/view/no_stretch_scroll_behavior.dart';
import '../create/home_create_type_dialog.dart';
import '../global/routes/app_pages.dart';
import '../global/user/user.dart';
import '../video/shared/home_assets.dart';
import '../video/shared/home_shared_widgets.dart';
import 'home_image_components.dart';

// bool _flushImageVisibilityOnVerticalScrollEnd(ScrollNotification notification) {
//   if (notification.metrics.axis == Axis.vertical &&
//       (notification is ScrollEndNotification ||
//           notification is UserScrollNotification &&
//               notification.direction == ScrollDirection.idle)) {
//     VisibilityDetectorController.instance.notifyNow();
//   }
//   return false;
// }

/// AI 图片首页。
///
/// 当前主要承接设计稿里的分类展示和顶部功能入口，点击后统一切到创作页。
class ImageTabPage extends StatelessWidget {
  ImageTabPage({
    required this.isActive,
    required this.onOpenPayment,
    required this.onOpenProfile,
    required this.onOpenSupport,
  });

  final bool isActive;
  final VoidCallback onOpenPayment;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSupport;

  final HomeImageController controller = Get.find<HomeImageController>();

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
                child: ScrollConfiguration(
                  behavior: const NoStretchScrollBehavior(),
                  child: NotificationListener<ScrollNotification>(
                    // onNotification: _flushImageVisibilityOnVerticalScrollEnd,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: ImageFeatureChip(
                                  label: '文生图',
                                  icon: Icons.draw_rounded,
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.create,
                                      arguments: {
                                        'entry': createTypeEntries[2],
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ImageFeatureChip(
                                  label: '参考生图',
                                  icon: Icons.add_photo_alternate_outlined,
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.create,
                                      arguments: {
                                        'entry': createTypeEntries[3],
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Obx(
                            () => Column(
                              children: controller.categries
                                  .map(
                                    (section) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 18,
                                      ),
                                      child: ImageSectionBlock(
                                        isActive: isActive,
                                        section: section,
                                        items:
                                            (controller.items[section.id
                                                        .toString()] ??
                                                    [])
                                                .cast(),
                                        onOpenMore: () {
                                          Get.toNamed(
                                            Routes.videoDetail,
                                            arguments: {
                                              'index': 0,
                                              'image': controller
                                                  .items[section.id.toString()],
                                              'title': section.title,
                                              'id': section.id,
                                              'video': [],
                                              'listScope': 'image',
                                            },
                                          );
                                        },
                                        onSelectItem: (index) {
                                          Get.toNamed(
                                            Routes.caseCreate,
                                            arguments: {
                                              'index': index,
                                              'image': controller
                                                  .items[section.id.toString()],
                                              'video': [],
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
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
