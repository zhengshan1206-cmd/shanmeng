/*
 * @Author: duncy
 * @Date: 2025-10-21 16:04:56
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:21:17
 * @FilePath: /ling_bao/lib/core/ui/dialog/system_dialog.dart
 * @Description: 
 */

import 'package:flutter/material.dart';

import '../../../global/ui/colors.dart';
import '../../util/by_screen_utils.dart';
import '../widget/by_button.dart';
import '../widget/by_text.dart';

///系统弹窗
class SystemDialog {
  OverlayEntry? _currentEntry;

  // 显示弹窗
  void show(BuildContext context, {required Widget child}) {
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;
    _currentEntry?.remove(); // 关闭已有弹窗
    _currentEntry = OverlayEntry(builder: (context) => child);
    overlay.insert(_currentEntry!);
  }

  // 关闭弹窗
  void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class SystemPopupDialog extends StatefulWidget {
  const SystemPopupDialog({super.key, this.close});

  final void Function()? close;

  @override
  State<SystemPopupDialog> createState() => _SystemPopupDialogState();
}

class _SystemPopupDialogState extends State<SystemPopupDialog> {
  late Offset _offset; // 控制平移的偏移量
  bool isClosed = false;

  @override
  void initState() {
    super.initState();
    // 初始偏移：从屏幕下方1000的位置（确保在屏幕外）
    _offset = const Offset(0, -100);

    // 组件首次构建完成后，触发动画（从初始偏移到目标位置）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _offset = Offset.zero; // 目标位置：不偏移（中心）
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          width: double.infinity,
          duration: Duration(milliseconds: 200),
          color: Colors.amber,
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          curve: Curves.bounceInOut,
          padding: EdgeInsets.symmetric(horizontal: 12),
          onEnd: () {
            if (isClosed) {
              widget.close?.call();
            }
          },
          child: Column(
            children: [
              SizedBox(height: ByScreenUtils.topSafeHeight),
              Container(
                height: 44,
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ByText.text(text: 'Test'),
                    const Spacer(),
                    ByButton.textButton(
                      title: 'Close',
                      titleColor: ByColor.colorF1,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _offset = Offset(0, -100);
                          isClosed = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
