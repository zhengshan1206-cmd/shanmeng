/*
 * @Author: cold-x
 * @Date: 2025-07-29 17:54:33
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:21:38
 * @FilePath: /ling_bao/lib/core/cache/daily_cache_manager.dart
 * @Description: 
 */

import 'byhy_aes_storage_utils.dart';

enum DailyManagerType {
  ///每日一次
  day,

  ///每日两次
  twicePerDay,

  ///两天一次
  twoDays,

  ///一周一次
  week,

  ///24小说
  twentyfourHous,
}

// 扩展String类转换为 CreationType
extension DailyManagerTypeExt on int {
  DailyManagerType toDailyManagerType() {
    switch (this) {
      case 2:
        return DailyManagerType.twicePerDay;
      case 3:
        return DailyManagerType.twoDays;
      case 4:
        return DailyManagerType.week;
      case 5:
        return DailyManagerType.twentyfourHous;
      default:
        return DailyManagerType.day;
    }
  }
}

class DailyManager {
  // 检查是否需要弹窗（返回 true 表示需要弹窗）
  static Future<bool> shouldShowPopup(
    String key, {
    DailyManagerType type = DailyManagerType.day,
  }) async {
    ///24小时
    if (type == DailyManagerType.twentyfourHous) {
      final now = DateTime.now().millisecondsSinceEpoch;
      int? timeDiff = ByStorageUtils.getInt(key);
      if (timeDiff == null) {
        return true;
      }
      timeDiff = timeDiff + 24 * 60 * 60 * 1000 - now;
      Duration tmpDur = Duration(milliseconds: timeDiff);
      return tmpDur.isNegative;
    }
    final currentDate = _getCurrentDateString();
    final lastDate = ByStorageUtils.getString(key);
    if (lastDate == null || lastDate.isEmpty) {
      return true;
    }
    // 首次使用（无记录）或跨天，需要弹窗
    if (type == DailyManagerType.day) {
      return lastDate != currentDate;
    } else if (type == DailyManagerType.twicePerDay) {
      ///使用,将日期和次数分割
      final lastDate = ByStorageUtils.getString(key);
      List<String> parts = lastDate!.split(",");
      if (parts.length < 2 ||
          parts.first != currentDate ||
          int.parse(parts.last) <= 2) {
        return true;
      } else {
        return false;
      }
    } else {
      DateTime date2 = DateTime.parse(lastDate);
      DateTime normalizedDate2 = DateTime(date2.year, date2.month, date2.day);
      int daysDiff = (normalizedDate2.difference(DateTime.now()).inDays).abs();
      return daysDiff <= (type == DailyManagerType.twoDays ? 2 : 7);
    }
  }

  // 记录当前日期为最后弹窗日期
  static Future<void> recordPopupDate(
    String key, {
    DailyManagerType type = DailyManagerType.day,
  }) async {
    if (type == DailyManagerType.twentyfourHous) {
      final now = DateTime.now().millisecondsSinceEpoch;
      ByStorageUtils.saveInt(key, now);
      return;
    }
    final currentDate = _getCurrentDateString();
    if (type != DailyManagerType.twicePerDay) {
      ByStorageUtils.saveString(key, currentDate);
    } else {
      ///使用,将日期和次数分割
      final lastDate = ByStorageUtils.getString(key);
      if (lastDate == null || lastDate.isEmpty) {
        ByStorageUtils.saveString(key, '$currentDate,1');
      } else {
        List<String> parts = lastDate.split(",");
        if (parts.length < 2) {
          ByStorageUtils.saveString(key, '$currentDate,1');
          return;
        }
        ByStorageUtils.saveString(
          key,
          '$currentDate,${int.parse(parts.last) + 1}',
        );
      }
    }
  }

  // 获取当前日期的字符串（格式：yyyy-MM-dd）
  static String _getCurrentDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
