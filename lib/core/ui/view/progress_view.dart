/*
 * @Author: cold-x
 * @Date: 2025-06-13 17:46:56
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-10-11 16:25:46
 * @FilePath: /novel_oversea/lib/core/ui/view/progress_view.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';

import '../../../global/ui/colors.dart';

// ignore: must_be_immutable
class ProgressView extends StatefulWidget {
  ProgressView({super.key, this.progress});

  double? progress = 0.0;

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.w),
        gradient: LinearGradient(
          colors: [
            ByColor.colorC1.withValues(alpha: 0.4),
            ByColor.colorF1.withValues(alpha: 0.4),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: widget.progress,
                  child: Container(
                    decoration: BoxDecoration(gradient: ByColor.colorG1()),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: ByText.text(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                textColor: Colors.black,
                text: 'Generating${(widget.progress! * 100).round()}%',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
