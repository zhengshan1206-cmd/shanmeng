// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

/// 项目里最常用的主按钮样式。
///
/// 登录、创作、支付等高优先级动作统一用这套粉色渐变按钮。
class PrimaryGradientButton extends StatelessWidget {
  const PrimaryGradientButton({
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: buttonKey,
      width: double.infinity,
      height: compact ? 50 : 49,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFD2B54), Color(0xFFFF6180)],
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x40FD2B54),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(90),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// 深色毛玻璃返回/关闭图标按钮。
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.buttonKey,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: buttonKey,
      width: 56,
      height: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 16),
          splashRadius: 18,
        ),
      ),
    );
  }
}

/// 通用深色面板容器。
///
/// 主要给底部弹窗使用，统一标题、说明文和主体内容的排版方式。
class FrostedSheet extends StatelessWidget {
  const FrostedSheet({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.64),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

/// 通用深色输入框。
class DarkTextField extends StatelessWidget {
  const DarkTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.34)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Color(0xFFFF6180)),
        ),
      ),
    );
  }
}

/// 套餐切换用的胶囊按钮。
class KindFilterChip extends StatelessWidget {
  const KindFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected
              ? const LinearGradient(
                  colors: <Color>[Color(0xFFFD2B54), Color(0xFFFF6180)],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// /// 支付弹窗内的套餐卡片。
// class PaymentPackageTile extends StatelessWidget {
//   const PaymentPackageTile({
//     required this.package,
//     required this.selected,
//     required this.onTap,
//   });

//   final PurchasePackage package;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(22),
//         child: Ink(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(22),
//             color: selected
//                 ? const Color(0x1FFD2B54)
//                 : Colors.white.withValues(alpha: 0.04),
//             border: Border.all(
//               color: selected
//                   ? const Color(0xFFFF6180)
//                   : Colors.white.withValues(alpha: 0.08),
//             ),
//           ),
//           child: Row(
//             children: <Widget>[
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 width: 22,
//                 height: 22,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: selected
//                       ? const Color(0xFFFF4B69)
//                       : Colors.transparent,
//                   border: Border.all(
//                     color: selected
//                         ? const Color(0xFFFF4B69)
//                         : Colors.white.withValues(alpha: 0.22),
//                   ),
//                 ),
//                 child: selected
//                     ? const Icon(Icons.check, color: Colors.white, size: 14)
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                       package.title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     if (package.description.isNotEmpty) ...<Widget>[
//                       const SizedBox(height: 4),
//                       Text(
//                         package.description,
//                         style: TextStyle(
//                           color: Colors.white.withValues(alpha: 0.62),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 package.displayPrice,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/// 小型胶囊标签。
class CapsuleTag extends StatelessWidget {
  const CapsuleTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// 背景发光圆斑。
class GlowOrb extends StatelessWidget {
  const GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: <Color>[color, Colors.transparent]),
        ),
      ),
    );
  }
}
