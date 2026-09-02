import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ling_bao/core/cache/byhy_aes_storage_utils.dart';
import 'package:ling_bao/global/const/const_string.dart';
import 'package:ling_bao/global/ui/colors.dart';

class CountdownView extends StatefulWidget {
  final double fontSize;
  final Color textColor;
  final Color bgColor;
  final Color separatorColor;
  final double timeItemWidth;
  final double borderRadius;
  final bool showMilliseconds;
  final int? type;
  final VoidCallback? timeOut;
  final int? seconds;
  final bool? showHours;
  final Color? borderColor;
  final double borderWidth;

  const CountdownView({
    super.key,
    this.fontSize = 12,
    this.textColor = ByColor.colorF5,
    this.bgColor = ByColor.color2E3038,
    this.separatorColor = ByColor.colorF3,
    this.timeItemWidth = 21,
    this.borderRadius = 6,
    this.showMilliseconds = false,
    this.type = 0,
    this.timeOut,
    this.seconds = 0,
    this.showHours = true,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

// 添加一个GlobalKey类型
typedef CountdownViewKey = GlobalKey<_CountdownViewState>;

class _CountdownViewState extends State<CountdownView> {
  late Duration _duration;
  Timer? _timer;
  int _milliseconds = 0;
  bool _showMilliseconds = true;
  int _beginTime = 0;

  @override
  void initState() {
    super.initState();
    getBeginTime();
    _duration = widget.type == 0 ? _getTodayRemain() : _getRemain();
    _showMilliseconds = widget.showMilliseconds;
    _startTimer();
  }

  ///获取开始时间
  void getBeginTime() {
    if (widget.type != 0) {
      _beginTime = ByStorageUtils.getInt(ConstString.kCancelPaySecondTime) ?? 0;
    } else {
      _beginTime = DateTime.now().second + widget.seconds!;
    }
  }

  ///当日剩余时间或者指定时间的剩余时间
  Duration _getTodayRemain() {
    final now = DateTime.now();
    if (widget.seconds == 0) {
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return end.difference(now).isNegative
          ? Duration.zero
          : end.difference(now);
    } else {
      final timeDiff = _beginTime - now.second;
      Duration tmpDur = Duration(seconds: timeDiff);
      if (tmpDur.isNegative) {
        widget.timeOut?.call();
      }
      return tmpDur.isNegative ? Duration.zero : tmpDur;
    }
  }

  ///指定时间的剩余时间
  Duration _getRemain() {
    getBeginTime();
    final now = DateTime.now().millisecondsSinceEpoch;
    final timeDiff =
        _beginTime + ConstString.kCancelPaySecondTimeDuration - now;
    Duration tmpDur = Duration(milliseconds: timeDiff);
    if (tmpDur.isNegative) {
      widget.timeOut?.call();
    }
    return tmpDur.isNegative ? Duration.zero : tmpDur;
  }

  void _startTimer() {
    _timer?.cancel();
    // 如果显示毫秒，则每50毫秒更新一次，否则每秒更新一次
    final interval = _showMilliseconds
        ? const Duration(milliseconds: 50)
        : const Duration(seconds: 1);

    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        _duration = widget.type == 0 ? _getTodayRemain() : _getRemain();
        if (_showMilliseconds) {
          _milliseconds = (1000 - DateTime.now().millisecond) % 1000;
        }
      });
    });
  }

  // 切换毫秒显示状态
  void toggleMilliseconds() {
    setState(() {
      _showMilliseconds = !_showMilliseconds;
    });
    _startTimer(); // 重新启动计时器以调整更新频率
  }

  // 设置毫秒显示状态
  void setMillisecondsVisible(bool visible) {
    if (_showMilliseconds != visible) {
      setState(() {
        _showMilliseconds = visible;
      });
      _startTimer(); // 重新启动计时器以调整更新频率
    }
  }

  // 获取当前毫秒显示状态
  bool get isMillisecondsVisible => _showMilliseconds;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _duration.inHours.toString().padLeft(2, '0');
    final minutes = (_duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (_milliseconds / 10).floor().toString().padLeft(
      2,
      '0',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showHours!) _buildTimeBox(hours),
        if (widget.showHours!) _buildSeparator(),
        _buildTimeBox(minutes),
        _buildSeparator(),
        _buildTimeBox(seconds),
        if (_showMilliseconds) ...[
          _buildSeparator(),
          _buildTimeBox(milliseconds),
        ],
      ],
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      width: widget.timeItemWidth,
      height: widget.timeItemWidth,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!, width: widget.borderWidth)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        time,
        style: TextStyle(
          color: widget.textColor,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          color: widget.separatorColor,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
