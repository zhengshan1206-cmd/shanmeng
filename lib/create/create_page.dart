/*
 * @Author: duncy
 * @Date: 2026-04-09 11:15:33
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-15 18:43:55
 * @FilePath: /ling_bao/lib/create/create_page.dart
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/page/base_page.dart';
import 'package:ling_bao/core/ui/view/no_stretch_scroll_behavior.dart';
import 'package:ling_bao/create/create_controller.dart';
import 'package:ling_bao/create/case/head_tail_upload_box.dart';
import 'package:ling_bao/create/case/multi_image_upload_box.dart';
import 'package:ling_bao/create/case/upload_box.dart';
import 'package:ling_bao/create/case/reference_upload_box.dart';
import 'package:ling_bao/global/user/user.dart';
import '../video/main/page/home_video_detail_page.dart';
import 'case/hot_case_view.dart';
import 'case/prompt_box.dart';
import 'case/radio_box.dart';

/// 参考图缩略图数据。
class CreateReferenceThumbData {
  const CreateReferenceThumbData({required this.assetPath});

  final String assetPath;
}

// ignore: must_be_immutable
class CreatePage extends BasePage {
  CreatePage({super.key});

  @override
  CreateController get controller => Get.find<CreateController>();

  @override
  String get title => controller.title;

  @override
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ScrollConfiguration(
              behavior: const NoStretchScrollBehavior(),
              child: SingleChildScrollView(
                // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                child: _buildModuleBody(),
              ),
            ),
          ),
          Obx(
            () => CreateFlowSubmitBar(
              enable: controller.canCreate.value,
              integral: controller.integralRights(),
              showIntegral: controller.rights.value != null,
              userIntegral: controller.rights.value?.userIntegral ?? 0,
              onClick: () {
                controller.startGenerate();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildActions(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: CurrencyBadge(
          value: controller.rights.value == null
              ? '${controller.getUserIntegral()}'
              : '${controller.rights.value?.userIntegral}',
        ),
      ),
    );
  }

  Widget _buildModuleBody() {
    switch (controller.type) {
      case CreateFlowType.imageToVideo:
      case CreateFlowType.textToVideo:
        return CreateSimpleVideoModule();
      case CreateFlowType.headTailVideo:
        return CreateHeadTailModule();
      case CreateFlowType.multiImageVideo:
        return const CreateMultiImageModule();
      case CreateFlowType.aiDraw:
      case CreateFlowType.aiEdit:
        return CreateSimpleVideoModule();
      case CreateFlowType.referenceImage:
        return CreateReferenceImageModule();
    }
  }
}

class CreateFlowSubmitBar extends StatelessWidget {
  const CreateFlowSubmitBar({
    super.key,
    required this.enable,
    this.onClick,
    this.integral = 0,
    this.showIntegral = true,
    this.userIntegral = 0,
    this.gotoPay,
    this.onBeforeTap,
  });

  final bool enable;
  final int integral;
  final bool showIntegral;
  final int userIntegral;
  final Function()? onClick;
  final Function()? gotoPay;
  final VoidCallback? onBeforeTap;

  @override
  Widget build(BuildContext context) {
    final UserController user = Get.find<UserController>();
    int current = userIntegral;
    if (current == 0) {
      current = user.userInfoBean.value?.integral ?? 0;
    }
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 48.w,
              decoration: BoxDecoration(
                gradient: enable
                    ? const LinearGradient(
                        colors: <Color>[Color(0xFFFF2C59), Color(0xFFFF4D72)],
                      )
                    : null,
                color: enable ? null : const Color(0xFF383838),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Stack(
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        onBeforeTap?.call();
                        if (integral > current) {
                          if (gotoPay == null) {
                            user.jumpToPayPage();
                          }
                          gotoPay?.call();
                          return;
                        }
                        user.checkPreLogin(
                          actionCallback: () {
                            onClick?.call();
                          },
                        );
                      },
                      child: Center(
                        child: Text(
                          '立即创作',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showIntegral)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        margin: const EdgeInsets.only(right: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Row(
                          crossAxisAlignment: .center,
                          children: <Widget>[
                            Icon(
                              Icons.add_circle_rounded,
                              color: Colors.white,
                              size: 15.w,
                            ),
                            SizedBox(width: 4),
                            Container(
                              height: 22.w,
                              alignment: .center,
                              child: Text(
                                integral.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '内容由AI生成，严禁用于非法活动',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.28),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateSimpleVideoModule extends StatelessWidget {
  CreateSimpleVideoModule({super.key});

  final CreateController controller = Get.find<CreateController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CreateHotCasesRow(),
        const SizedBox(height: 14),
        if (controller.type == CreateFlowType.imageToVideo)
          CreateUploadBox(type: controller.type),
        if (controller.type == CreateFlowType.imageToVideo)
          const SizedBox(height: 14),
        const CreateSectionTitle(
          title: 'AI创意描述',
          subtitle: '(根据图片描述想要生成的画面和动作)',
        ),
        const SizedBox(height: 10),
        CreatePromptBox(hint: '请输入你想要的内容', enabled: true),
        if ([
          CreateFlowType.textToVideo,
          CreateFlowType.aiDraw,
        ].contains(controller.type))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const CreateSectionTitle(title: '画面比例', subtitle: ''),
              const SizedBox(height: 10),
              CreateRatioRow(
                onSelected: (ratio) {
                  controller.ratioChanged(ratio);
                },
              ),
            ],
          ),
      ],
    );
  }
}

class CreateReferenceImageModule extends StatelessWidget {
  CreateReferenceImageModule({super.key});

  final CreateController controller = Get.find<CreateController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CreateReferenceUploadBox(),
        const SizedBox(height: 18),
        const CreateSectionTitle(title: 'AI创意描述'),
        const SizedBox(height: 10),
        CreatePromptBox(hint: '请输入你想要的内容', enabled: true),
      ],
    );
  }
}

class CreateHeadTailModule extends StatelessWidget {
  const CreateHeadTailModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CreateHeadTailUploadBox(),
        const SizedBox(height: 18),
        const CreateSectionTitle(
          title: 'AI创意描述',
          subtitle: '(根据图片描述想要生成的画面和动作)',
        ),
        const SizedBox(height: 10),
        CreatePromptBox(hint: '请输入你想要的内容', enabled: true),
      ],
    );
  }
}

class CreateMultiImageModule extends StatelessWidget {
  const CreateMultiImageModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CreateMultiImageUploadBox(),
        const SizedBox(height: 18),
        const CreateSectionTitle(
          title: 'AI创意描述',
          subtitle: '(根据图片描述想要生成的画面和动作)',
        ),
        const SizedBox(height: 10),
        CreatePromptBox(hint: '请输入你想要的内容', enabled: true),
      ],
    );
  }
}
