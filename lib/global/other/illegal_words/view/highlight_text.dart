/*
 * @Author: cold-x
 * @Date: 2025-06-18 19:08:47
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-18 19:26:55
 * @FilePath: /fastcreationmaster/lib/global/other/illegal_words/view/highlight_text.dart
 * @Description: 
 */
import 'dart:math';

import 'package:flutter/material.dart';

class HighlightTextRange {
  int start;
  int end;

  HighlightTextRange(this.start, this.end);
}

class MultiHighlightText extends StatelessWidget {
  final String text;
  final List<String> highlights;
  final TextStyle? normalStyle;
  final TextStyle? highlightStyle;

  MultiHighlightText({
    Key? key,
    required this.text,
    required this.highlights,
    this.normalStyle,
    this.highlightStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Text(text, style: normalStyle);
    }

    final List<TextSpan> children = [];
    List<HighlightTextRange> matches = [];

    // 收集所有匹配位置
    for (final highlight in highlights) {
      final regex = RegExp(RegExp.escape(highlight));
      for (final match in regex.allMatches(text)) {
        matches.add(HighlightTextRange(match.start, match.end));
      }
    }

    // 按起始位置排序并合并重叠区域
    matches.sort((a, b) => a.start.compareTo(b.start));
    List<HighlightTextRange> mergedMatches = [];

    for (final match in matches) {
      if (mergedMatches.isEmpty) {
        mergedMatches.add(match);
      } else {
        final last = mergedMatches.last;
        if (match.start <= last.end) {
          mergedMatches.removeLast();
          mergedMatches.add(HighlightTextRange(last.start, max(last.end, match.end)));
        } else {
          mergedMatches.add(match);
        }
      }
    }

    // 构建高亮文本
    int lastIndex = 0;
    for (final match in mergedMatches) {
      if (match.start > lastIndex) {
        children.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: normalStyle,
        ));
      }

      children.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle ?? TextStyle(color: Colors.red),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      children.add(TextSpan(
        text: text.substring(lastIndex),
        style: normalStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: children),
    );
  }
}

// // 使用示例
// MultiHighlightText(
//   text: 'Hello Flutter and Dart!',
//   highlights: ['Flutter', 'Dart'],
//   highlightStyle: TextStyle(color: Colors.red),
// )