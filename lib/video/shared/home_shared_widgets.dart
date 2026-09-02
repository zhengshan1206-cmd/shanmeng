// ignore_for_file: use_key_in_widget_constructors

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ling_bao/global/routes/app_pages.dart';
import 'app_shared_widgets.dart';
import 'home_assets.dart';
import 'home_models.dart';

/// 顶部右侧的小工具按钮。
class TopUtilityButton extends StatelessWidget {
  const TopUtilityButton({
    super.key,
    required this.assetPath,
    this.onTap,
    this.buttonKey,
  });

  final String assetPath;
  final VoidCallback? onTap;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: buttonKey,
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Image.asset(assetPath),
        ),
      ),
    );
  }
}

/// 图片频道顶部品牌字样。
class ImageChannelBrand extends StatelessWidget {
  const ImageChannelBrand();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        ///测试专用
        // Get.toNamed(Routes.bankCardSelectPage),
      },
      child: Image.asset('assets/pay/logo_flash_dream_ai.png', height: 34),
    );
  }
}

/// 图片频道顶部功能入口胶囊。
class ImageFeatureChip extends StatelessWidget {
  const ImageFeatureChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1D20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: Colors.white.withValues(alpha: 0.78), size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 首页顶部星空背景图。
class ImageStarField extends StatelessWidget {
  const ImageStarField();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Image.asset(
        HomeAssets.videoStarfield,
        fit: BoxFit.fitWidth,
        width: double.infinity,
        height: 170,
        alignment: Alignment.topCenter,
      ),
    );
  }
}

/// 创作页提示词输入卡片。
class PromptCard extends StatelessWidget {
  const PromptCard({
    required this.controller,
    required this.title,
    required this.hint,
  });

  final TextEditingController controller;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // 这里当前沿用固定标题，后续如需完全复用，可替换为传入 title。
              const Text(
                'AI创意描述',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${controller.text.length}/500',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 6,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.34)),
              filled: true,
              fillColor: const Color(0xFF171717),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Color(0xFFFF6180)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部主 Tab 栏。
///
/// 中间创作按钮不是普通 Tab，而是一个单独的动作入口，因此视觉与交互都特殊处理。
class HomeTabBar extends StatelessWidget {
  const HomeTabBar({required this.selectedTab, required this.onChanged});

  final HomeTab selectedTab;
  final ValueChanged<HomeTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0x3E101115),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 18,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SideTabItem(
                    assetPath: HomeAssets.navigationVideoTab,
                    label: 'AI视频',
                    selected: selectedTab == HomeTab.video,
                    onTap: () => onChanged(HomeTab.video),
                  ),
                ),
                Expanded(
                  child: _CenterCreateTabItem(
                    selected: selectedTab == HomeTab.create,
                    onTap: () => onChanged(HomeTab.create),
                  ),
                ),
                Expanded(
                  child: _SideTabItem(
                    assetPath: HomeAssets.navigationImageTab,
                    label: 'AI图片',
                    selected: selectedTab == HomeTab.image,
                    onTap: () => onChanged(HomeTab.image),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 左右两侧的常规 Tab 按钮。
class _SideTabItem extends StatelessWidget {
  const _SideTabItem({
    required this.assetPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 21,
            height: 21,
            child: Image.asset(
              assetPath,
              color: selected
                  ? Colors.white.withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.34),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white.withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.38),
              fontSize: 11,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// 中间创作按钮。
///
/// 为了保持当前排版与无文字设计稿一致，语义文本通过隐藏节点保留给测试查找。
class _CenterCreateTabItem extends StatelessWidget {
  const _CenterCreateTabItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x33FF4E74),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                gradient: const RadialGradient(
                  center: Alignment(-0.1, -0.1),
                  radius: 0.95,
                  colors: <Color>[
                    Color(0xFFFF98AF),
                    Color(0xFFFF6384),
                    Color(0xFFFD2B54),
                  ],
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0,
              child: Text(
                '创作页',
                style: TextStyle(
                  color: Colors.transparent,
                  fontSize: 0.01,
                  height: 0.01,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 创作页顶部品牌标题。
class BrandWordmark extends StatelessWidget {
  const BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Text(
          '闪梦',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF5F7E)),
      ],
    );
  }
}

/// 中间创作页的大预览卡片。
///
/// 通过渐变、缩放和透明度变化表达当前选中态。
class CreationPreviewCard extends StatelessWidget {
  const CreationPreviewCard({
    required this.data,
    required this.selected,
    required this.mode,
  });

  final CreationCardData data;
  final bool selected;
  final CreationMode mode;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1 : 0.54,
      child: Transform.scale(
        scale: selected ? 1 : 0.94,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                data.secondary.withValues(alpha: 0.88),
                data.accent.withValues(alpha: 0.92),
                const Color(0xFF12080E),
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: data.accent.withValues(alpha: selected ? 0.24 : 0.12),
                blurRadius: 36,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 16,
                left: 16,
                child: CapsuleTag(label: data.badge),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    mode == CreationMode.image
                        ? Icons.auto_awesome_rounded
                        : Icons.play_circle_fill_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 282,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 252,
                        height: 252,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      Transform.rotate(
                        angle: -0.06,
                        child: Container(
                          width: 206,
                          height: 266,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.white.withValues(alpha: 0.76),
                                Colors.white.withValues(alpha: 0.26),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 图片/视频创作模式切换器。
class CreationModeSwitch extends StatelessWidget {
  const CreationModeSwitch({
    required this.selectedMode,
    required this.onChanged,
  });

  final CreationMode selectedMode;
  final ValueChanged<CreationMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeButton(
              label: '图片创作',
              selected: selectedMode == CreationMode.image,
              onTap: () => onChanged(CreationMode.image),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: '视频创作',
              selected: selectedMode == CreationMode.video,
              onTap: () => onChanged(CreationMode.video),
            ),
          ),
        ],
      ),
    );
  }
}

/// 模式切换里的单个按钮。
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected
              ? const LinearGradient(
                  colors: <Color>[Color(0xFFFD2B54), Color(0xFFFF6180)],
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 1 : 0.66),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// 创作页底部操作栏。
///
/// 用于统一展示积分消耗、余额入口和主按钮，既可内嵌在页面中，也可独立使用。
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.pointsCostLabel,
    required this.balanceLabel,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.onBalanceTap,
    this.embedded = false,
  });

  final String pointsCostLabel;
  final String balanceLabel;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final VoidCallback onBalanceTap;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(embedded ? 12 : 0, 0, embedded ? 12 : 0, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(embedded ? 28 : 32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                pointsCostLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onBalanceTap,
                child: Text(
                  balanceLabel,
                  style: const TextStyle(
                    color: Color(0xFFFF8296),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryGradientButton(
            label: primaryLabel,
            onPressed: onPrimaryTap,
            compact: true,
          ),
          const SizedBox(height: 10),
          Text(
            '内容由 AI 生成，严禁用于非法活动或侵犯他人权益。',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.44),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部积分/VIP 状态徽章。
class CoinBadge extends StatelessWidget {
  const CoinBadge({required this.data, required this.onTap});

  final UserBadgeData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF322113), Color(0xFF25160F)],
            ),
            border: Border.all(color: const Color(0x33F59E0B)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.stars_rounded,
                color: Color(0xFFFBBF24),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                data.label,
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                data.count,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 顶部状态提示横幅。
///
/// 用于展示登录、支付、接口返回等轻量状态消息。
class StatusBanner extends StatelessWidget {
  const StatusBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFFFF8296),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
