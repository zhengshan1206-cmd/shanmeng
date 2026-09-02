/*
 * @Author: duncy
 * @Date: 2026-04-09 13:35:06
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-18 17:19:02
 * @FilePath: /ling_bao/lib/create/case/hot_case_view.dart
 * @Description:
 */
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/create/create_controller.dart';

import '../../core/ui/view/by_widgets_util.dart';

/// 创作页热门案例数据。

class CreateHotCasesRow extends StatelessWidget {
  CreateHotCasesRow({super.key});

  final CreateController controller = Get.find<CreateController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Row(
          children: <Widget>[
            Text('🔥', style: TextStyle(fontSize: 18)),
            SizedBox(width: 4),
            Text(
              '热门案例',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.isVideoCreate()
                  ? controller.hotList.length
                  : controller.hotImagesList.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                String url = '';
                String title = '';
                if (controller.isVideoCreate()) {
                  url = controller.hotList[index].coverUrl;
                  title =
                      controller.hotList[index].title?.trim().isNotEmpty == true
                      ? controller.hotList[index].title!.trim()
                      : (controller.hotList[index].prompt ?? '');
                } else {
                  url = controller.hotImagesList[index].picUrl;
                  title = controller.hotImagesList[index].displayTitle;
                }
                return GestureDetector(
                  onTap: () {
                    controller.openHotCase(index);
                  },
                  child: _CreateCaseCard(url: url, title: title),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateCaseCard extends StatelessWidget {
  const _CreateCaseCard({required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: double.infinity,
                  placeholder: (context, url) {
                    return ByWidgetsUtil.activityIndicator(isNormal: false);
                  },
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    height: 20,
                    color: Color(0x66090D10),
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    child: ByText.text(text: title, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
