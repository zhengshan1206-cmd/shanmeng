/*
 * @Author: cold-x
 * @Date: 2025-06-16 15:25:41
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-16 11:28:46
 * @FilePath: /novel_oversea/lib/core/ui/view/share_view.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/by_screen_utils.dart';
import 'package:ling_bao/global/ui/colors.dart';

///分享网页至微信好有、微信朋友圈
class ShareView extends StatelessWidget {
  const ShareView({
    super.key,
    this.title = 'Ai小说创作精灵',
    this.desc = '',
    required this.webURL,
  });

  ///网页链接
  final String webURL;

  ///标题
  final String? title;

  ///描述
  final String? desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      height: 213.w + ByScreenUtils.bottomSafeHeight,
      color: ByColor.colorBg1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: SizedBox(
              child: Image.asset(
                'assets/global/common/btn_close.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          SizedBox(height: 44.w),
          Row(
            children: [
              SizedBox(width: 84.w),
              _buildShareItem(
                'assets/global/common/btn_wechat_friend.png',
                '分享给朋友',
              ),
              SizedBox(width: 53.w),
              _buildShareItem(
                'assets/global/common/btn_wechat_moments.png',
                '分享给朋友圈',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareItem(String image, String shareType) {
    return GestureDetector(
      onTap: () {
        share(shareType);
      },
      child: Column(
        children: [
          Image.asset(image, width: 44.w, height: 44.w),
          SizedBox(height: 8.w),
          ByText.text(textColor: ByColor.colorF2, text: shareType),
        ],
      ),
    );
  }

  void share(String shareType) async {
    // bool isInstalled = await WechatKitPlatform.instance.isInstalled();
    // final Uint8List? thumbData = await rootBundle.load('assets/thumb_icon.png')
    //   .then((data) => data.buffer.asUint8List());
    // if (isInstalled) {
    //   await WechatKitPlatform.instance.shareWebpage(
    //     title: title,
    //     scene: shareType == '分享给朋友' ? WechatScene.kSession : WechatScene.kTimeline,
    //     thumbData: thumbData,
    //     description: desc,
    //     webpageUrl: webURL,
    //   );
    //   Get.back();
    // }
    // else {
    //   Toast.showText(text: '您尚未安装微信，无法分享');
    // }
  }
}
