// 个人中心模块的共用外观组件。
import 'package:flutter/material.dart';

/// 个人中心页面统一骨架。
class ProfilePageScaffold extends StatelessWidget {
  const ProfilePageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050506),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
      ),
      body: Stack(
        children: <Widget>[
          // 背景发光层统一放在骨架里，子页面只关心自身内容区。
          const Positioned(
            top: -100,
            left: -70,
            child: _GlowOrb(size: 240, color: Color(0x18FF4B6A)),
          ),
          const Positioned(
            top: 180,
            right: -90,
            child: _GlowOrb(size: 230, color: Color(0x14306BFF)),
          ),
          SafeArea(top: false, child: child),
        ],
      ),
    );
  }
}

/// 个人中心分组卡片容器。
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

/// 个人中心通用列表项。
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          // 分割线由 showDivider 控制，最后一项可关闭底边线保持卡片完整。
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  )
                : null,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.54),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.56),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 个人中心概览区统计卡片。
class ProfileStatTile extends StatelessWidget {
  const ProfileStatTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 退出登录/注销账号等高风险操作按钮。
class ProfileDangerButton extends StatelessWidget {
  const ProfileDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.highlighted = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    // 高亮态用于“登录正式账号”，普通危险态用于退出/注销等操作。
    final Color foreground = highlighted
        ? Colors.white
        : const Color(0xFFFF9AAE);
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: highlighted
              ? const Color(0x26FF4B6A)
              : Colors.white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: highlighted
                  ? const Color(0x40FF4B6A)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// 个人中心背景发光圆斑。
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: <Color>[color, Colors.transparent]),
      ),
    );
  }
}
