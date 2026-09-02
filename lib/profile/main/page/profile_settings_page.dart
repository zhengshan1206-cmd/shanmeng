// 个人中心设置页。
// 按 design/个人中心/设置.png 重新组织为多组卡片列表和底部描边按钮，同时保留
// 协议、投诉、备案、订阅管理等功能入口。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/ui/dialog/diolog_view.dart';
import 'package:ling_bao/global/launch/controller/launch_manager.dart';
import 'package:ling_bao/global/routes/app_pages.dart';
import 'package:ling_bao/global/ui/colors.dart';
import 'package:ling_bao/global/user/user.dart';
import 'package:ling_bao/profile/main/controller/set_up_controller.dart';
import 'profile_about_page.dart';

/// 设置页入口。
class ProfileSettingsPage extends StatelessWidget {
  ProfileSettingsPage({
    super.key,
    required this.identity,
    required this.onOpenLogin,
    required this.onOpenPayment,
  });

  final UserController identity;
  final Future<void> Function() onOpenLogin;
  final Future<void> Function() onOpenPayment;

  final SetupController controller = Get.put(SetupController());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: identity,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: <Widget>[
                      _SettingsTopButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          '设置',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                    children: <Widget>[
                      _SettingsGroupCard(
                        children: <Widget>[
                          _SettingsItem(
                            icon: Icons.layers_outlined,
                            title: '订阅管理',
                            onTap: () async {
                              await Get.toNamed(Routes.orderManagement);
                            },
                          ),
                          Obx(
                            () => _SettingsItem(
                              icon: Icons.notifications_none_rounded,
                              title: '消息通知',
                              showDot: controller.unreadMessageCount.value > 0,
                              showDivider: false,
                              onTap: () async {
                                await Get.toNamed(Routes.message);
                                controller.getUnreadMessageCount();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsGroupCard(
                        children: <Widget>[
                          _SettingsItem(
                            icon: Icons.article_outlined,
                            title: '用户协议',
                            onTap: () => _openLinkPage(context, title: '用户协议'),
                          ),
                          _SettingsItem(
                            icon: Icons.person_outline_rounded,
                            title: '隐私政策',
                            onTap: () => _openLinkPage(context, title: '隐私政策'),
                          ),
                          _SettingsItem(
                            icon: Icons.report_gmailerrorred_outlined,
                            title: '投诉举报',
                            showDivider: false,
                            onTap: () => _openLinkPage(context, title: '投诉举报'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsGroupCard(
                        children: <Widget>[
                          _SettingsItem(
                            icon: Icons.verified_user_outlined,
                            title: '算法备案',
                            onTap: () =>
                                _openLinkPage(context, title: '算法备案公示'),
                          ),
                          _SettingsItem(
                            icon: Icons.info_outline_rounded,
                            title: '关于我们',
                            showDivider: false,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ProfileAboutPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!identity.isVisitor)
                  _BottomOutlineAction(
                    label: '退出登录',
                    onTap: () async {
                      if (identity.isVisitor) {
                        await onOpenLogin();
                        return;
                      }
                      await _confirmLogout(context);
                    },
                  ),
                if (!identity.isVisitor) const SizedBox(height: 8),
                if (!identity.isVisitor)
                  _BottomTextAction(
                    label: '注销账号',
                    onTap: () async {
                      await _confirmDeleteAccount(context);
                    },
                  ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openLinkPage(BuildContext context, {required String title}) {
    GlobalController.instance.config.goPrivacyPageWithTitle(title);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (dialogContext) => NovelDialog(
        title: '退出登录',
        content: '确定退出当前账号吗？退出后会恢复为游客模式。',
        onConfirm: () {
          controller.logout();
        },
      ),
    );

    if (confirmed != true) {
      return;
    }

    // await identity.logout();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已退出登录')));
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (dialogContext) => NovelDialog(
        title: '注销账号',
        contentAlign: TextAlign.left,
        content:
            "1、账户一旦注销，该账户下的信息、数据、记录将全部删除，且无法恢复。\n\n2、注销后，账户下的全部权益均被清除:且无法恢复。\n\n3、注销后，该账户绑定的第三方账户将被解除绑定，您可重新使用并注册成为新用户。\n\n4、提交注销后将在三个工作日内完成数据清除",
        onConfirm: () {
          controller.deleteAccount();
        },
      ),
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已提交注销申请')));
  }
}

class _SettingsTopButton extends StatelessWidget {
  const _SettingsTopButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  const _SettingsGroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
    this.showDot = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                )
              : null,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Colors.white.withValues(alpha: 0.64), size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
            ),
            if (showDot)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: ByColor.colorG4,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.44),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomOutlineAction extends StatelessWidget {
  const _BottomOutlineAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 250,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomTextAction extends StatelessWidget {
  const _BottomTextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
