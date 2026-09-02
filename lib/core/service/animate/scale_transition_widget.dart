import 'package:flutter/material.dart';

class ScaleTransitionWidget extends StatefulWidget {
  final Widget child;
  final double? min;
  final double? max;
  final int? period;
  const ScaleTransitionWidget({
    super.key,
    required this.child,
    this.min,
    this.max,
    this.period,
  });

  @override
  State<ScaleTransitionWidget> createState() => _ScaleTransitionWidgetState();
}

class _ScaleTransitionWidgetState extends State<ScaleTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.period ?? 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.min ?? 0.95,
      end: widget.max ?? 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            filterQuality: FilterQuality.high,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
