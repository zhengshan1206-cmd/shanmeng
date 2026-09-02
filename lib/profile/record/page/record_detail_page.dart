/*
 * @Author: duncy
 * @Date: 2026-04-10 13:55:17
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-05-18 17:21:20
 * @FilePath: /ling_bao/lib/profile/record/page/record_detail_page.dart
 * @Description: 
 */
/*
 * @Author: duncy
 * @Date: 2026-04-10 13:55:17
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-10 13:59:55
 * @FilePath: /ling_bao/lib/profile/record/page/record_detail_page.dart
 * @Description: 
 */
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/page/base_page.dart';
import 'package:ling_bao/core/ui/view/video/byhy_video_player_view.dart';
import 'package:ling_bao/global/launch/page/bottom_view.dart';
import 'package:ling_bao/profile/record/controller/record_detail_controller.dart';

import '../../../global/ui/colors.dart';
import '../../../video/shared/home_models.dart';

// ignore: must_be_immutable
class RecordDetailPage extends BasePage {
  RecordDetailPage({super.key});

  @override
  String get title => '作品详情';

  @override
  RecordDetailController get controller => Get.find<RecordDetailController>();

  @override
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: controller.mode == CreationMode.video
                  ? (controller.url.isNotEmpty
                        ? VideoPlayerWidget(
                            url: controller.url,
                            autoPlay: true,
                            mute: false,
                          )
                        : (controller.videoCoverUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: controller.videoCoverUrl,
                                  fit: BoxFit.contain,
                                )
                              : const Center(
                                  child: Text(
                                    '视频地址为空',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )))
                  : CachedNetworkImage(
                      imageUrl: controller.url,
                      fit: BoxFit.contain,
                      progressIndicatorBuilder: (context, url, progress) {
                        return const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) => const Center(
                        child: Text(
                          '加载失败',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
            ),
          ),
          BottomView(
            showWords: false,
            showNextIcon: false,
            nextBtnText: '保存到手机',
            titleColor: ByColor.colorF0,
            nextStep: () {
              controller.saveToPhone();
            },
          ),
          // SizedBox(height: 10),
          Text(
            '内容由AI生成，严禁用于非法活动',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.28),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
