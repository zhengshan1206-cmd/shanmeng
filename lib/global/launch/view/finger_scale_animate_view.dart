import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ling_bao/global/ui/colors.dart';

class FingerScaleAnimateView extends StatefulWidget {
  const FingerScaleAnimateView({super.key, this.showCave = true});

  final bool showCave;

  @override
  State<FingerScaleAnimateView> createState() => _FingerScaleAnimateViewState();
}

class _FingerScaleAnimateViewState extends State<FingerScaleAnimateView>
    with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          if (widget.showCave)
            Transform.translate(
              offset: Offset(-32.5.w, -22.5.w),
              child: const ExpandedAnimateView(),
            ),
          SizedBox(
            width: 74.w,
            height: 67.w,
            child: AnimatedBuilder(
              animation: _aniController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  origin: Offset(-32.w, -10.w),
                  child: Image.asset(
                    'assets/pay/guide_home_step_finger.png',
                    width: 74.w,
                    height: 67.w,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedAnimateView extends StatefulWidget {
  const ExpandedAnimateView({super.key});

  @override
  State<ExpandedAnimateView> createState() => _ExpandedAnimateViewState();
}

class _ExpandedAnimateViewState extends State<ExpandedAnimateView>
    with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    // 3. 透明度动画：从 1.0（完全显示）→ 0.0（完全消失）
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 与缩放动画用同一曲线
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 75.w,
        height: 75.w,
        child: Stack(
          children: [
            _bulildSingleView(0, 4),
            _bulildSingleView(1, 4),
            _bulildSingleView(2, 4),
            _bulildSingleView(3, 4),
          ],
        ),
      ),
    );
  }

  Widget _bulildSingleView(int index, int count) {
    double avg = 1 / count;
    return Center(
      child: AnimatedBuilder(
        animation: _aniController,
        builder: (context, child) {
          double op = _opacityAnimation.value + avg * index >= 1
              ? _opacityAnimation.value - avg * (count - index)
              : _opacityAnimation.value + avg * index;
          double sc = _scaleAnimation.value + avg * (count - index) > 1.0
              ? _scaleAnimation.value - avg * index
              : _scaleAnimation.value + avg * (count - index);
          return Opacity(
            opacity: op,
            child: Transform.scale(
              scale: sc,
              child: Container(
                width: 75.w,
                height: 75.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(37.5.w),
                  // color: Color(0xFF53EC27),
                  color: op > 0.5 ? ByColor.colorF1 : Colors.transparent,
                  border: Border.all(width: 3, color: ByColor.colorF1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }
}
