/*
 * @Author: cold-x
 * @Date: 2025-07-15 10:33:12
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-16 17:03:15
 * @FilePath: /novel_oversea/lib/core/ui/view/scroll_text_view.dart
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:ling_bao/core/util/extentions.dart';

class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Duration pause;
  final double velocity;

  const AutoScrollText(
    this.text, {
    super.key,
    this.style = const TextStyle(),
    this.duration = const Duration(seconds: 5),
    this.pause = const Duration(seconds: 2),
    this.velocity = 300.0,
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late ScrollController _controller;
  late AnimationController _animationController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  ///停止滚动
  void stopScrolling() {
    _isScrolling = false;
    _animationController.stop();
  }

  ///开始滚动
  void startScrolling() {
    // 延迟启动滚动，确保文本已布局
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  Future<void> _startScrolling() async {
    if (!mounted || _controller.position.maxScrollExtent <= 0 || _isScrolling)
      return;
    _isScrolling = true;
    try {
      while (mounted && _controller.hasClients) {
        // 等待一段时间再开始滚动
        await Future.delayed(widget.pause);

        // 滚动到末尾
        await _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: widget.duration,
          curve: Curves.linear,
        );

        // 等待一段时间再反向滚动
        await Future.delayed(widget.pause);

        // 滚动回起点
        // await _controller.animateTo(
        //   0.0,
        //   duration: widget.duration,
        //   curve: Curves.linear,
        // );
        _controller.jumpTo(0.0); // 直接跳转到起点，避免动画
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算文本宽度
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: double.infinity);
        // print('_______textPainter.width: ${textPainter.width}, constraints.maxWidth: ${constraints.maxWidth}');
        // 如果文本宽度超过约束宽度，启用滚动
        if (textPainter.width + 10 > constraints.maxWidth) {
          startScrolling();
          return SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Text(widget.text.loc, style: widget.style, maxLines: 1),
          );
        }
        stopScrolling();
        // 文本未超出宽度，直接显示
        return Text(widget.text.loc, style: widget.style, maxLines: 1);
      },
    );
  }
}
