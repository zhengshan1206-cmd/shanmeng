// 个人中心主页。
// 按 design/个人中心/个人中心.png 重新组织为“顶部操作区 + VIP 横幅 + 作品 tabs +
// 作品网格”的结构，同时保留现有支付、客服和设置入口。

import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ling_bao/core/service/animate/scale_transition_widget.dart';
import 'package:ling_bao/core/ui/widget/by_button.dart';
import 'package:ling_bao/core/ui/widget/by_refresh.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/core/util/byhy_download_util.dart';
import 'package:ling_bao/core/util/clipboard.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/login/controller/login_manager.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:ling_bao/profile/main/controller/profile_controller.dart';
import '../../../global/routes/app_pages.dart';
import '../../integral/bean/video_works_bean.dart';
import '../bean/ai_draw_img_details_bean.dart';
import 'profile_settings_page.dart';

enum GenerateCategory { all, video, image }

enum _GenerateStatus { success, fail, loading }

/// 个人中心首页。
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = Get.find<ProfileController>();

  bool _hasRecords(GenerateCategory category) {
    return category == GenerateCategory.video
        ? controller.videoList.isNotEmpty
        : controller.imgList.isNotEmpty;
  }

  bool _hasMore(GenerateCategory category) {
    return category == GenerateCategory.video
        ? controller.videoHasMore.value
        : controller.imageHasMore.value;
  }

  RefreshController _refreshControllerOf(GenerateCategory category) {
    return category == GenerateCategory.video
        ? controller.videoRefreshManager.refreshController
        : controller.imageRefreshManager.refreshController;
  }

  VoidCallback _onRefreshOf(GenerateCategory category) {
    return () {
      if (category == GenerateCategory.video) {
        controller.loadVideoList(true);
      } else {
        controller.loadAllPictures(isRefresh: true);
      }
    };
  }

  VoidCallback _onLoadingOf(GenerateCategory category) {
    return () {
      if (category == GenerateCategory.video) {
        controller.loadVideoList(false);
      } else {
        controller.loadAllPictures(isRefresh: false);
      }
    };
  }

  Widget _buildRecordSection(GenerateCategory category) {
    if (controller.user.isVisitor) {
      return SizedBox(
        height: 300.h,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Image.asset('assets/global/common/icon_visitor.png', height: 120.w),
            SizedBox(height: 10.w),
            ByText.text(text: '还未登录'),
            SizedBox(height: 10.w),
            SizedBox(
              width: 80.w,
              height: 32.w,
              child: ByButton.textButton(
                title: '去登录',
                padding: EdgeInsets.zero,
                titleColor: ByColor.colorF1,
                fontSize: 13.sp,
                onPressed: () {
                  LoginManager.login(source: 'profile');
                },
              ),
            ),
          ],
        ),
      );
    }
    if (!_hasRecords(category)) {
      return SizedBox(
        height: 300.w,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Image.asset(
              'assets/global/common/icon_content_empty.png',
              width: 200.w,
              height: 150.w,
            ),
            SizedBox(height: 10.h),
            ByText.text(text: '暂无数据', textColor: ByColor.colorF3),
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: category == GenerateCategory.video
          ? controller.videoList.length
          : controller.imgList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (context, index) {
        if (category == GenerateCategory.video) {
          final VideoWorksBean item = controller.videoList[index];
          return GestureDetector(
            onTap: () => controller.openRecord(.video, item),
            child: _VideoCard(
              item: item,
              delete: () {
                controller.deleteRecord(
                  isVideo: true,
                  ids: [item.id],
                  index: index,
                  videoSource: item.videoSource,
                );
              },
            ),
          );
        }
        final AiDrawImgDetailsBean item = controller.imgList[index];
        return GestureDetector(
          onTap: () => controller.openRecord(.image, item),
          child: _ImageCard(
            item: item,
            delete: () {
              controller.deleteRecord(
                isVideo: false,
                ids: [item.id],
                index: index,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRefreshPage(GenerateCategory category) {
    return ByRefresh.refresh(
      refresherKey: ValueKey('profile_${category.name}'),
      controller: _refreshControllerOf(category),
      enablePullDown: !controller.user.isVisitor,
      enablePullUp:
          !controller.user.isVisitor &&
          _hasRecords(category) &&
          _hasMore(category),
      hideFooterWhenNotFull: false,
      header: ByRefresh.buildDarkHeader(),
      footer: ByRefresh.buildDarkFooter(hideNoMore: true),
      onRefresh: controller.user.isVisitor ? null : _onRefreshOf(category),
      onLoad: controller.user.isVisitor ? null : _onLoadingOf(category),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Obx(
                () => _ProfileAvatar(
                  avatarUrl: controller.user.userInfoBean.value?.avatar ?? '',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (controller.user.isVisitor) {
                          LoginManager.login(source: 'profile');
                        }
                      },
                      child: Obx(
                        () => Text(
                          controller.user.userInfoBean.value?.nickName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ClipboardManager.clip(
                          '${controller.user.userInfoBean.value?.userId}',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Obx(
                              () => Text(
                                'ID: ${controller.user.userInfoBean.value?.userId}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.38),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Image.asset(
                              'assets/profile/icon_profile_copy.png',
                              width: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.creditsItemList);
                },
                child: Transform.translate(
                  offset: Offset(12.w, 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        topLeft: Radius.circular(10),
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xA0A25D1A), Color(0xA0593D22)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/profile/icon_profile_credits.png',
                          width: 20.w,
                        ),
                        SizedBox(width: 4.w),
                        Obx(
                          () => ByText.text(
                            text:
                                '${controller.user.userInfoBean.value?.integral}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Obx(
            () => _VipBanner(
              isVisitor: controller.user.isVisitor,
              isVip: controller.user.isVip,
              userVipEndTime:
                  controller.user.userInfoBean.value?.vipEndTime ??
                  DateTime.now(),
              buttonKey: controller.user.isVisitor
                  ? const Key('profile-login-button')
                  : const Key('profile-payment-entry'),
              onTap: () {
                controller.user.jumpToPayPage();
              },
            ),
          ),
          const SizedBox(height: 18),
          Obx(
            () => _WorkTabBar(
              selectedCategory: controller.selectedCategory.value,
              onChanged: controller.changeCategory,
            ),
          ),
          const SizedBox(height: 12),
          const _RetentionBanner(),
          const SizedBox(height: 12),
          Obx(() => _buildRecordSection(category)),
          Obx(
            () =>
                !controller.user.isVisitor &&
                    _hasRecords(category) &&
                    !_hasMore(category)
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        '没有更多了',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _ProfileBackground()),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: <Widget>[
                      _TopCircleAction(
                        icon: 'assets/global/common/btn_back.png',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      _TopCircleAction(
                        icon: 'assets/video/icons/top_support.png',
                        onTap: () {
                          /// 客服
                          GlobalController.instance.config
                              .goPrivacyPageWithTitle('在线客服');
                        },
                      ),
                      const SizedBox(width: 10),
                      _TopCircleAction(
                        icon: 'assets/profile/icon_profile_settings.png',
                        buttonKey: const Key('profile-settings-button'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProfileSettingsPage(
                                identity: controller.user,
                                onOpenLogin: () async {},
                                onOpenPayment: () async {},
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(
                    () =>
                        controller.selectedCategory.value ==
                            GenerateCategory.video
                        ? _buildRefreshPage(GenerateCategory.video)
                        : _buildRefreshPage(GenerateCategory.image),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF140404),
            Color(0xFF000000),
            Color(0xFF000000),
          ],
          stops: <double>[0, 0.28, 1],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -60,
            left: -30,
            right: -30,
            child: Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.08,
                  colors: <Color>[Color(0x88A51818), Color(0x00000000)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCircleAction extends StatelessWidget {
  const _TopCircleAction({
    required this.icon,
    required this.onTap,
    this.buttonKey,
  });

  final String icon;
  final VoidCallback onTap;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: buttonKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(icon, color: Colors.white, width: 20),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = avatarUrl.trim().isNotEmpty;
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipOval(
        child: hasAvatar
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const _AvatarFallback(),
              )
            : const _AvatarFallback(),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF321312),
      child: const Center(
        child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}

class _VipBanner extends StatelessWidget {
  const _VipBanner({
    required this.isVisitor,
    required this.isVip,
    required this.onTap,
    required this.userVipEndTime,
    this.buttonKey,
  });

  final bool isVisitor;
  final bool isVip;
  final DateTime userVipEndTime;
  final VoidCallback onTap;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final String buttonLabel = isVip ? '会员续费' : '戳我领取';
    final String subtitle = '超多会员权益等你体验';
    final DateFormat format = DateFormat('yyyy-MM-dd');
    return Container(
      height: 85.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: .fill,
          image: AssetImage(
            'assets/profile/icon_profile_${isVip ? 'vip' : 'tourist'}_bg.png',
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 42.w,
            height: 42.w,
            child: Image.asset('assets/profile/icon_profile_vip_logo.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  'assets/profile/icon_profile_vip${isVip ? '' : '_title'}.png',
                  height: 22.w,
                ),
                const SizedBox(height: 6),
                Text(
                  isVip ? '到期时间: ${format.format(userVipEndTime)}' : subtitle,
                  style: TextStyle(
                    color: isVip
                        ? Color(0xFF906037)
                        : Colors.white.withValues(alpha: 0.68),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          if (!isVip)
            ScaleTransitionWidget(
              min: 0.95,
              max: 1.05,
              period: 900,
              child: GestureDetector(
                key: buttonKey,
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFFFFD0DE),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      color: Color(0xFF7A1E25),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkTabBar extends StatelessWidget {
  const _WorkTabBar({required this.selectedCategory, required this.onChanged});

  final GenerateCategory selectedCategory;
  final ValueChanged<GenerateCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Expanded(
        //   child: _WorkTabItem(
        //     label: '全部作品',
        //     selected: selectedCategory == GenerateCategory.all,
        //     onTap: () => onChanged(GenerateCategory.all),
        //   ),
        // ),
        Expanded(
          child: _WorkTabItem(
            label: '视频作品',
            selected: selectedCategory == GenerateCategory.video,
            onTap: () => onChanged(GenerateCategory.video),
          ),
        ),
        Expanded(
          child: _WorkTabItem(
            label: '图片作品',
            selected: selectedCategory == GenerateCategory.image,
            onTap: () => onChanged(GenerateCategory.image),
          ),
        ),
      ],
    );
  }
}

class _WorkTabItem extends StatelessWidget {
  const _WorkTabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 0.96 : 0.34),
            fontSize: 16.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RetentionBanner extends StatelessWidget {
  const _RetentionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2621),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: const Color(0xFFD1A35B).withValues(alpha: 0.88),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '文件仅保留7天，请尽快下载保存',
              style: TextStyle(
                color: const Color(0xFFD1A35B).withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 视频卡片
class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.item, this.delete});

  final VideoWorksBean item;
  final Function? delete;

  @override
  Widget build(BuildContext context) {
    _GenerateStatus status = item.isProcessing
        ? .loading
        : item.isFail
        ? .fail
        : .success;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Positioned.fill(
                  child: _WorkPreview(
                    status: status,
                    coverUrl: item.coverUrl,
                    videoUrl: item.videoUrl,
                    desc: '预计生成时间10-15分钟',
                  ),
                ),
                if (status != .loading)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => delete?.call(),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    color: status == .success ? null : const Color(0xFF41332F),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item.createAt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

/// 视频卡片
class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.item, this.delete});

  final AiDrawImgDetailsBean item;
  final Function? delete;

  @override
  Widget build(BuildContext context) {
    _GenerateStatus status = item.status == 0
        ? .fail
        : item.status == 3
        ? .success
        : .loading;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Positioned.fill(
                  child: _WorkPreview(
                    status: status,
                    coverUrl: item.picUrl,
                    desc: '预计生成时间10-15分钟',
                  ),
                ),
                if (status != .loading)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => delete?.call(),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    color: item.status == 3 ? null : const Color(0xFF41332F),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

class _WorkPreview extends StatelessWidget {
  const _WorkPreview({
    required this.status,
    required this.coverUrl,
    required this.desc,
    this.videoUrl,
  });

  final _GenerateStatus status;
  final String coverUrl;
  final String? videoUrl;
  final String desc;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case .success:
        return coverUrl.isEmpty
            ? FutureBuilder(
                future: ByDownloadUtil.generateThumbnail(videoUrl!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.file(File(snapshot.data!), fit: BoxFit.cover);
                  }
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0xFF414141), Color(0xFF222222)],
                      ),
                    ),
                  );
                },
              )
            : CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover);
      case .loading:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF414141), Color(0xFF222222)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '生成中...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      case .fail:
        return Container(
          color: const Color(0xFF2A2A2A),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.broken_image_outlined,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.74),
                ),
                const SizedBox(height: 10),
                const Text(
                  '生成失败',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
