/*
 * @Author: cold-x
 * @Date: 2025-05-15 16:05:27
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-17 17:27:59
 * @FilePath: /novel_oversea/lib/core/cache/cache.dart
 * @Description: 数据本地化模块(shared_preferences)
 */



import 'package:shared_preferences/shared_preferences.dart';

class CacheKeys {
  CacheKeys._();
  
  //版本检查
  static const versionCheck = 'version_check'; 
}

class LocalCacheManager {
  // 保存数据
  static Future<void> saveJsonData(String cacheKey, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data.isNotEmpty) {
      await prefs.setString(cacheKey, data);
    }
  }

  // 读取数据
  static Future<String> readJsonData(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    // 读取值，提供默认值以防止返回null
    try {
      final String? jsonData = prefs.getString(cacheKey);
      return jsonData!;
    } catch (e){
      return '';
    } finally {

    }
  }

  // 删除数据
  static Future<void> removeJsonData(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (cacheKey.isEmpty) {
      return;
    }
    // 删除指定的键
    await prefs.remove(cacheKey);
  }

  // 清除所有数据
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

